////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 by Michael A. Morris, dba M. A. Morris & Associates
//
//  All rights reserved. The source code contained herein is publicly released
//  under the terms and conditions of the GNU Lesser Public License. No part of
//  this source code may be reproduced or transmitted in any form or by any
//  means, electronic or mechanical, including photocopying, recording, or any
//  information storage and retrieval system in violation of the license under
//  which the source code is released.
//
//  The souce code contained herein is free; it may be redistributed and/or 
//  modified in accordance with the terms of the GNU Lesser General Public
//  License as published by the Free Software Foundation; either version 2.1 of
//  the GNU Lesser General Public License, or any later version.
//
//  The souce code contained herein is freely released WITHOUT ANY WARRANTY;
//  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
//  PARTICULAR PURPOSE. (Refer to the GNU Lesser General Public License for
//  more details.)
//
//  A copy of the GNU Lesser General Public License should have been received
//  along with the source code contained herein; if not, a copy can be obtained
//  by writing to:
//
//  Free Software Foundation, Inc.
//  51 Franklin Street, Fifth Floor
//  Boston, MA  02110-1301 USA
//
//  Further, no use of this source code is permitted in any form or means
//  without inclusion of this banner prominently in any derived works. 
//
//  Michael A. Morris
//  Huntsville, AL
//
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates 
// Engineer:        Michael A. Morris 
// 
// Create Date:     09:15:23 11/03/2012 
// Design Name:     WDC W65C02 Microprocessor Re-Implementation
// Module Name:     M65C02_AddrGen.v
// Project Name:    C:\XProjects\ISE10.1i\MAM65C02 
// Target Devices:  Generic SRAM-based FPGA 
// Tool versions:   Xilinx ISE10.1i SP3
//
// Description:
//
//  This file provides the M65C02_Core module's address generator function. This
//  module is taken from the address generator originally included in the
//  M65C02_Core module. The only difference is the addition of an explicit sig-
//  nal which generates relative offset for conditional branches, Rel.
//
// Dependencies:    none 
//
// Revision: 
//
//  0.00    12K03   MAM     Initial File Creation
//
//  1.00    12K03   MAM     Added Mod256 input to control Zero Page addressing.
//                          Reconfigured the stack pointer logic to reduce the
//                          number of adders used in its implementation. Opti-
//                          mized the PC logic using the approach used for the
//                          next address logic, NA.
//
//  1.10    12K12   MAM     Changed name of input signal Mod256 to ZP. When ZP
//                          is asserted, AO is computed modulo 256.
//
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////

module M65C02_AddrGen(
    input   Rst,                    // System Reset
    input   Clk,                    // System Clock

    input   [15:0] Vector,          // Interrupt/Trap Vector

    input   [3:0] NA_Op,            // Next Address Operation
    input   [1:0] PC_Op,            // Program Counter Operation
    input   [1:0] Stk_Op,           // Stack Pointer Operation
    
    input   ZP,                     // Modulo 256 Control Input
    
    input   CC,                     // Conditional Branch Input Flag
    input   BRV3,                   // Interrupt or Next Instruction Select
    input   Int,                    // Unmasked Interrupt Request Input

    input   Rdy,                    // Ready Input
    
    input   [7:0] DI,               // Memory Data Input
    input   [7:0] OP1,              // Operand Register 1 Input
    input   [7:0] OP2,              // Operand Register 2 Input
    input   [7:0] StkPtr,           // Stack Pointer Input
    
    input   [7:0] X,                // X Index Register Input
    input   [7:0] Y,                // Y Index Register Input

    output  [15:0] AO,              // Address Output

    output  reg [15:0] AL,          // Address Generator Left Operand
    output  reg [15:0] AR,          // Address Generator Right Operand
    output  reg [15:0] NA,          // Address Generator Output - Next Address
    output  reg [15:0] MAR,         // Memory Address Register
    output  reg [15:0] PC,          // Program Counter
    output  reg [15:0] dPC          // Delayed Program Counter - Interrupt Adr
);

////////////////////////////////////////////////////////////////////////////////
//
//  Local Parameters
//

localparam  pNA_Inc  = 4'h1;    // NA <= PC + 1
localparam  pNA_MAR  = 4'h2;    // NA <= MAR + 0
localparam  pNA_Nxt  = 4'h3;    // NA <= MAR + 1
localparam  pNA_Stk  = 4'h4;    // NA <= SP + 0
localparam  pNA_DPN  = 4'h5;    // NA <= {0, OP1} + 0
localparam  pNA_DPX  = 4'h6;    // NA <= {0, OP1} + {0, X}
localparam  pNA_DPY  = 4'h7;    // NA <= {0, OP1} + {0, Y}
localparam  pNA_LDA  = 4'h8;    // NA <= {OP2, OP1} + 0
//
//
//
//
//
localparam  pNA_LDAX = 4'hE;    // NA <= {OP2, OP1} + {0, X}
localparam  pNA_LDAY = 4'hF;    // NA <= {OP2, OP1} + {0, Y}

////////////////////////////////////////////////////////////////////////////////
//
//  Module Declarations
//

wire    CE_MAR;                 // Memory Address Register Clock Enable
wire    CE_PC;                  // Program Counter Clock Enable

wire    [15:0] Rel;             // Branch Address Sign-Extended Offset
reg     [15:0] PCL, PCR;        // Program Counter Left and Right Operands
reg     PC_Ci;                  // Program Counter Carry Input (Increment)

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

//  Next Address Generator

always @(*)
begin
    if(Rst)
        AL <= Vector;
    else
        case(NA_Op)
            4'b0000 : AL <= PC;                 // Reserved (default)
            4'b0001 : AL <= PC;                 // NA <= PC + 1
            4'b0010 : AL <= MAR;                // NA <= MAR + 0
            4'b0011 : AL <= MAR;                // NA <= MAR + 1
            4'b0100 : AL <= {8'b1, StkPtr};     // NA <= SP + 0
            4'b0101 : AL <= {8'b0, OP1};        // NA <= {0, OP1} + 0
            4'b0110 : AL <= {8'b0, OP1};        // NA <= {0, OP1} + {0, X}
            4'b0111 : AL <= {8'b0, OP1};        // NA <= {0, OP1} + {0, Y}
            4'b1000 : AL <= { OP2, OP1};        // Reserved
            4'b1001 : AL <= { OP2, OP1};        // NA <= {OP2, OP1} + 0
            4'b1010 : AL <= { OP2, OP1};        // NA <= {OP2, OP1} + 0
            4'b1011 : AL <= { OP2, OP1};        // NA <= {OP2, OP1} + 0
            4'b1100 : AL <= { OP2, OP1};        // NA <= {OP2, OP1} + 0
            4'b1101 : AL <= { OP2, OP1};        // NA <= {OP2, OP1} + 0
            4'b1110 : AL <= { OP2, OP1};        // NA <= {OP2, OP1} + {0, X}
            4'b1111 : AL <= { OP2, OP1};        // NA <= {OP2, OP1} + {0, Y}
        endcase
end

always @(*)
begin
    if(Rst)
        AR <= 0;
    else
        case(NA_Op)
            4'b0000 : AR <= 0;                  // Rserved (default)
            4'b0001 : AR <= 1;                  // NA <= PC  + 1
            4'b0010 : AR <= 0;                  // NA <= MAR + 0
            4'b0011 : AR <= 1;                  // NA <= MAR + 1
            4'b0100 : AR <= 0;                  // NA <= SP  + 0
            4'b0101 : AR <= 0;                  // NA <= {  0, OP1} + 0
            4'b0110 : AR <= {8'b0, X};          // NA <= {  0, OP1} + {0, X}
            4'b0111 : AR <= {8'b0, Y};          // NA <= {  0, OP1} + {0, Y}
            4'b1000 : AR <= 0;                  // NA <= {OP2, OP1} + 0
            4'b1001 : AR <= 0;                  // NA <= {OP2, OP1} + 0
            4'b1010 : AR <= 0;                  // NA <= {OP2, OP1} + 0
            4'b1011 : AR <= 0;                  // NA <= {OP2, OP1} + 0
            4'b1100 : AR <= 0;                  // NA <= {OP2, OP1} + 0
            4'b1101 : AR <= 0;                  // NA <= {OP2, OP1} + 0
            4'b1110 : AR <= {8'b0, X};          // NA <= {OP2, OP1} + {0, X}
            4'b1111 : AR <= {8'b0, Y};          // NA <= {OP2, OP1} + {0, Y}
        endcase
end

always @(*) NA = AL + AR;

assign AO = ((ZP) ? {8'b0, NA[7:0]} : NA);

//  Memory Address Register

assign CE_MAR = (|NA_Op) & Rdy;

always @(posedge Clk)
begin
    if(Rst)
        MAR <= #1 Vector;
    else if(CE_MAR)
        MAR <= #1 AO;
end

//  Program Counter

assign CE_PC = ((BRV3) ? ((|PC_Op) & ~Int) : (|PC_Op)) & Rdy;

//  Generate Relative Address

assign Rel = ((CC) ? {{8{DI[7]}}, DI} : 0);

always @(*)
begin
    case({PC_Op, Stk_Op})
        //
        4'b0000 : PCL <= PC;                    // NOP: PC
        4'b0001 : PCL <= PC;                    // NOP: PC
        4'b0010 : PCL <= PC;                    // NOP: PC
        4'b0011 : PCL <= PC;                    // NOP: PC
        //
        4'b0100 : PCL <= PC;                    // Pls: PC + 1
        4'b0101 : PCL <= PC;                    // Pls: PC + 1
        4'b0110 : PCL <= PC;                    // Pls: PC + 1
        4'b0111 : PCL <= PC;                    // Pls: PC + 1
        //
        4'b1000 : PCL <= { DI, OP1};            // Jmp: JMP
        4'b1001 : PCL <= { DI, OP1};            // Jmp: JMP
        4'b1010 : PCL <= {OP2, OP1};            // Jmp: JSR
        4'b1011 : PCL <= { DI, OP1};            // Jmp: RTS/RTI
        //
        4'b1100 : PCL <= PC;                    // Rel:  Bcc
        4'b1101 : PCL <= PC;                    // Rel:  Bcc
        4'b1110 : PCL <= PC;                    // Rel:  Bcc
        4'b1111 : PCL <= PC;                    // Rel:  Bcc
    endcase
end

always @(*) PCR <= ((&PC_Op) ? Rel : 0);        // Rel

always @(*)
begin
    case({PC_Op, Stk_Op})
        //
        4'b0000 : PC_Ci <= 0;                   // NOP: PC
        4'b0001 : PC_Ci <= 0;                   // NOP: PC
        4'b0010 : PC_Ci <= 0;                   // NOP: PC
        4'b0011 : PC_Ci <= 0;                   // NOP: PC
        //
        4'b0100 : PC_Ci <= 1;                   // Pls: PC + 1
        4'b0101 : PC_Ci <= 1;                   // Pls: PC + 1
        4'b0110 : PC_Ci <= 1;                   // Pls: PC + 1
        4'b0111 : PC_Ci <= 1;                   // Pls: PC + 1
        //
        4'b1000 : PC_Ci <= 0;                   // Jmp: JMP
        4'b1001 : PC_Ci <= 0;                   // Jmp: JMP
        4'b1010 : PC_Ci <= 0;                   // Jmp: JSR
        4'b1011 : PC_Ci <= 1;                   // Jmp: RTS/RTI
        //
        4'b1100 : PC_Ci <= 1;                   // Rel:  Bcc
        4'b1101 : PC_Ci <= 1;                   // Rel:  Bcc
        4'b1110 : PC_Ci <= 1;                   // Rel:  Bcc
        4'b1111 : PC_Ci <= 1;                   // Rel:  Bcc
    endcase
end

always @(posedge Clk)
begin
    if(Rst)
        PC <= #1 Vector;
    else if(CE_PC)
        PC <= #1 (PCL + PCR + PC_Ci);
end

//  Track past values of the PC for interrupt handling
//      past value of PC required to correctly determine the address of the
//      instruction at which the interrupt trap was taken. The automatic incre-
//      ment of the return address following RTS/RTI will advance the address 
//      so that it points to the correct instruction.

always @(posedge Clk)
begin
    if(Rst)
        dPC <= #1 Vector;
    else if(CE_PC)
        dPC <= #1 PC;
end

endmodule
