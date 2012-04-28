///////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

///////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates
// Engineer:        Michael A. Morris
//
// Create Date:     21:38:27 02/04/2012
// Design Name:     M65C02_Core - WDC W65C02 Microprocessor Re-Implementation
// Module Name:     tb_MAM65C02_Core.v
// Project Name:    C:/XProjects/ISE10.1i/MAM6502
// Target Device:   XC3S200AN-4FT256I 
// Tool versions:   Xilinx ISE 10.1i SP3
//  
// Description: 
//
// Verilog Test Fixture created by ISE for module: M65C02_Core
//
// Dependencies:
// 
// Revision:
// 
//  0.01    12B04   MAM     Initial coding. 
//
// Additional Comments:
// 
///////////////////////////////////////////////////////////////////////////////

module tb_M65C02_Core;

    parameter pRst_Vector = 16'h0210;
    parameter pIRQ_Vector = 16'h021B;
    parameter pBrk_Vector = 16'h021B;
    
    parameter pInt_Hndlr  = 9'h021;
    
    parameter pIRQ_On     = 16'hFFFE;
    parameter pIRQ_Off    = 16'hFFFF;
    
    parameter pIO_WR      = 2'b01;
    
    parameter pRAM_AddrWidth = 11;

    // System

    reg  Rst;                   // System Reset
    reg  Clk;                   // System Clock

    //  Processor

    wire IRQ_Msk;               // Interrupt Mask Bit from P
    reg  Int;                   // Interrupt Request
    reg  [15:0] Vector;         // Interrupt Vector

    wire Done;                  // Instruction Complete
    wire SC;                    // Single Cycle Instruction
    wire [2:0] Mode;            // Instruction Type/Mode
    wire RMW;                   // Read-Modify-Write Operation
    wire IntSvc;                // Interrupt Service Start
    
    wire Rdy;                   // Internal Ready

    wire [1:0] IO_Op;           // Bus Operation: 1 - WR; 2 - RD; 3 - IF
    reg  Ack;                   // Read/Write Data Transfer Acknowledge

    wire [15:0] AO;             // Address Output Bus
    wire [ 7:0] DI;             // Data Input Bus
    wire [ 7:0] DO;             // Data Output Bus

	wire [ 7:0] A;              // Internal Register - Accumulator
	wire [ 7:0] X;              // Internal Register - Pre-Index Register X
	wire [ 7:0] Y;              // Internal Register - Post-Index Register Y
	wire [ 7:0] S;              // Internal Register - Stack Pointer
	wire [ 7:0] P;              // Internal Register - Program Status Word
	wire [15:0] PC;             // Internal Register - Program Counter
        
	wire [7:0] IR;              // Internal Register - Instruction Register
	wire [7:0] OP1;             // Internal Register - Operand Register 1
	wire [7:0] OP2;             // Internal Register - Operand Register 2
    
    // Simulation Variables
    
    reg     Sim_Int    = 0;

    integer cycle_cnt  = 0;
    integer instr_cnt  = 0;
    
    integer Loop_Start = 0;         // Flags the first loop
    
    integer Hist_File  = 0;         // File handle for instruction histogram
    integer SV_Output  = 0;         // File handle for State Vector Outputs
    
    reg     [15:0] Hist [255:0];    // Instruction Histogram array
    reg     [15:0] val;             // Instruction Histogram variable
    reg     [ 7:0] i, j;            // loop counters
    
// Instantiate the Unit Under Test (UUT)

M65C02_Core #(
                .pInt_Hndlr(pInt_Hndlr),
                .pM65C02_uPgm("M65C02_uPgm_V3.coe"),
                .pM65C02_IDec("M65C02_Decoder_ROM.coe")
            ) uut (
            .Rst(Rst), 
            .Clk(Clk), 
            
            .IRQ_Msk(IRQ_Msk), 
            .Int(Int), 
            .Vector(Vector), 
            
            .Done(Done),
            .SC(SC),
            .Mode(Mode), 
            .RMW(RMW),
            .IntSvc(IntSvc),

            .Rdy(Rdy),
            
            .IO_Op(IO_Op), 
            .Ack_In(Ack), 
            
            .AO(AO), 
            .DI(DI), 
            .DO(DO), 
            
            .A(A), 
            .X(X), 
            .Y(Y), 
            .S(S), 
            .P(P), 
            .PC(PC), 
            
            .IR(IR), 
            .OP1(OP1), 
            .OP2(OP2)
        );
            
//  Instantiate RAM Module

M65C02_RAM  #(
                .pAddrSize(pRAM_AddrWidth),
                .pDataSize(8),
                .pFileName("M65C02_Tst2.txt")
            ) RAM (
                .Clk(Clk),
                .WE((IO_Op == 1)),
                .AI(AO[(pRAM_AddrWidth - 1):0]),
                .DI(DO),
                .DO(DI)
            );

initial begin
    // Initialize Inputs
    Rst    = 1;
    Clk    = 1;
    Int    = 0;
    Vector = pRst_Vector;
    Ack    = 1;
    
    //  Initialize Instruction Execution Histogram array
    
    for(cycle_cnt = 0; cycle_cnt < 256; cycle_cnt = cycle_cnt + 1)
        Hist[cycle_cnt] = 0;
    cycle_cnt = 0;
    
    Hist_File = $fopen("M65C02_Hist_File.txt", "w");
    SV_Output = $fopen("M65C02_SV_Output.txt", "w");

    // Wait 100 ns for global reset to finish
    
    #101 Rst = 0;
    
    // Add stimulus here
    
end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
//  Clocks
//

always #5 Clk = ~Clk;

///////////////////////////////////////////////////////////////////////////////
//
//  Reset/NMI/Brk/IRQ Vector Generator
//

always @(*)
begin
    Vector = ((&Mode) ? pBrk_Vector : ((Int) ? pIRQ_Vector : pRst_Vector));
end

// Simulate Interrupts

always @(*)
begin
    if((AO == pIRQ_On) && (IO_Op == pIO_WR))
        Sim_Int = 1;
    else if((AO == pIRQ_Off) && (IO_Op == pIO_WR))
        Sim_Int = 0;
end

always @(*)
begin
    Int = ((IRQ_Msk) ? 0 : Sim_Int);
end

//  Count number of cycles and the number of instructions between between
//      0x0210 and the repeat at 0x0210 

always @(posedge Clk)
begin
    if(Rst)
        cycle_cnt = 0;
    else
        cycle_cnt = ((Done & (AO == 16'h0210)) ? 1 : (cycle_cnt + 1));
end

always @(posedge Clk)
begin
    if(Rst)
        instr_cnt = 0;
    else if(Done & Rdy)
        instr_cnt = ((AO == 16'h0210) ? 1 : (instr_cnt + 1));
end

//  Perform Instruction Histogramming for coverage puposes

always @(posedge Clk)
begin
    $fstrobe(SV_Output, "%b, %b, %b, %h, %b, %b, %h, %b, %b, %b, %h, %b, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h",
             IRQ_Msk, Sim_Int, Int, Vector, Done, SC, Mode, RMW, IntSvc, Rdy, IO_Op, Ack, AO, DI, DO, A, X, Y, S, P, PC, IR, OP1, OP2);

    if(Done & Rdy) begin
        if((AO == 16'h0210)) begin
            if((Loop_Start == 1)) begin
                for(i = 0; i < 16; i = i + 1)
                    for(j = 0; j < 16; j = j + 1) begin
                        val = Hist[(j * 16) + i];
                        Hist[(j * 16) + i] = 0;
                        if((j == 0))
                            $fwrite(Hist_File, "\n%h : %h", ((j * 16) + i), val);
                        else
                            $fwrite(Hist_File, " %h", val);
                    end
                $fclose(Hist_File);
                $fclose(SV_Output);

                $display("\nTest Loop Complete\n");

                $stop;
            end else begin
                Loop_Start = 1;
            end
        end
        val = Hist[IR];
        Hist[IR] = val + 1;
    end
end

//  Test Monitor System Function
//
//    wire IRQ_Msk;               // Interrupt Mask Bit from P
//    wire Sim_Int;               // Simulated Interrupt Request
//    reg  Int;                   // Interrupt Request
//    reg  [15:0] Vector;         // Interrupt Vector
//
//    wire Done;                  // Instruction Complete
//    wire SC;                    // Single Cycle Instruction
//    wire [2:0] Mode;            // Instruction Type/Mode
//    wire RMW;                   // Read-Modify-Write Operation
//    wire IntSvc;                // Interrupt Service Start
//    
//    wire Rdy;                   // Internal Ready
//
//    wire [1:0] IO_Op;           // Bus Operation: 1 - WR; 2 - RD; 3 - IF
//    reg  Ack;                   // Read/Write Data Transfer Acknowledge
//
//    wire [15:0] AO;             // Address Output Bus
//    wire [ 7:0] DI;             // Data Input Bus
//    wire [ 7:0] DO;             // Data Output Bus
//
//	wire [ 7:0] A;              // Internal Register - Accumulator
//	wire [ 7:0] X;              // Internal Register - Pre-Index Register X
//	wire [ 7:0] Y;              // Internal Register - Post-Index Register Y
//	wire [ 7:0] S;              // Internal Register - Stack Pointer
//	wire [ 7:0] P;              // Internal Register - Program Status Word
//	wire [15:0] PC;             // Internal Register - Program Counter
//        
//	wire [7:0] IR;              // Internal Register - Instruction Register
//	wire [7:0] OP1;             // Internal Register - Operand Register 1
//	wire [7:0] OP2;             // Internal Register - Operand Register 2

always @(*)
begin
    $monitor("%b, %b, %b, %h, %b, %b, %h, %b, %b, %b, %h, %b, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h",
             IRQ_Msk, Sim_Int, Int, Vector, Done, SC, Mode, RMW, IntSvc, Rdy, IO_Op, Ack, AO, DI, DO, A, X, Y, S, P, PC, IR, OP1, OP2);
end

endmodule
