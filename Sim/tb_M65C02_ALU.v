///////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2006-2012 by Michael A. Morris, dba M. A. Morris & Associates
//
//  All rights reserved. The source code contained herein is publicly released
//  under the terms an conditions of the GNU Lesser Public License. No part of
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
// Create Date:     09:02:48 11/28/2009
// Design Name:     W65C02_ALU
// Module Name:     C:/XProjects/ISE10.1i/MAM6502/tb_W65C02_ALU.v
// Project Name:    MAM6502
// Target Device:   SRAM-based FPGA  
// Tool versions:   Xilinx ISE 10.1i SP3
//  
// Description: 
//
// Verilog Test Fixture created by ISE for module: W65C02_ALU
//
// Dependencies:
// 
// Revision:
// 
//  0.01    09K28   MAM     Initial coding
//
// Additional Comments:
//
//  The simulation performs checks against expected results. A test vector file
//  could have been used. However, the vector would have been more difficult to
//  interpret and construct. Although this implementation is a brute force
//  approach, the test vectors as defined in this file can be used to construct
//  the "fixed" microprogram ROM. Only the En input field does not belong in
//  the "fixed" microcode ROM, i.e. instruction decoder ROM.
//
///////////////////////////////////////////////////////////////////////////////

module tb_M65C02_ALU;

///////////////////////////////////////////////////////////////////////////////

localparam pNOP  = 0;       // No Operation

//  Logic Unit
localparam pALU_NOP = 0;    // NOP - No Operation: ALU <= {OSel: 0,A,X,Y,P,S,M}
localparam pALU_AND = 1;    // AND - bitwise AND Accumulator with Memory
localparam pALU_ORA = 2;    // ORA - bitwise OR Accumulator with Memory
localparam pALU_EOR = 3;    // EOR - bitwise XOR Accumulator with Memory
//  Arithmetic Unit
localparam pALU_ADC = 4;    // ADC - Add Memory to Accumulator plus Carry
localparam pALU_SBC = 5;    // SBC - Sub Memory from Accumulator plus Carry
localparam pALU_INC = 6;    // INC - Increment {A, X, Y, or M}
localparam pALU_DEC = 7;    // DEC - Decrement {A, X, Y, or M}
//  Shift Unit
localparam pALU_ASL = 8;    // ASL - Arithmetic Shift Left {A, or M}
localparam pALU_LSR = 9;    // LSR - Logical Shift Right {A, or M}
localparam pALU_ROL = 10;   // ROL - Rotate Left through Carry {A, or M}
localparam pALU_ROR = 11;   // ROR - Rotate Right through Carry {A, or M}
//  Bit Unit
localparam pALU_BIT = 12;   // BIT - Test Memory with Bit Mask in Accumulator
localparam pALU_TRB = 13;   // TRB - Test and Reset Memory with Bit Mask in A
localparam pALU_TSB = 14;   // TSB - Test and Set Memory with Bit Mask in A
//  Compare Unit
localparam pALU_CMP = 15;    

//  QSel = 0; RSel = 0; Sub = 0; CSel = 0; WSel/OSel Register Select Field Codes

localparam pSel_A   = 1;    // Select Accumulator
localparam pSel_X   = 2;    // Select X Index
localparam pSel_Y   = 3;    // Select Y Index
localparam pSel_Z   = 4;    // Select Zero
localparam pSel_P   = 5;    // Select PSW
localparam pSel_S   = 6;    // Select Stack Pointer
localparam pSel_M   = 7;    // Select Memory Operand 

//  Condition Code Select

localparam pCC   = 8;       // Carry Clear
localparam pCS   = 9;       // Carry Set
localparam pNE   = 10;      // Not Equal to Zero
localparam pEQ   = 11;      // Equal to Zero
localparam pVC   = 12;      // Overflow Clear
localparam pVS   = 13;      // Overflow Set
localparam pPL   = 14;      // Plus (Not Negative)
localparam pMI   = 15;      // Negative
localparam pCLC  = 16;      // Clear C
localparam pSEC  = 17;      // Set Carry
localparam pCLI  = 18;      // Clear Interrupt mask
localparam pSEI  = 19;      // Set Interrupt mask
localparam pCLD  = 20;      // Clear Decimal mode
localparam pSED  = 21;      // Set Decimal mode
localparam pCLV  = 22;      // Clear Overflow
localparam pBRK  = 23;      // Set BRK flag
localparam pZ    = 24;      // Set Z = ~|(A & M)
localparam pNZ   = 25;      // Set N and Z flags from ALU
localparam pNZC  = 26;      // Set N, Z, and C flags from ALU
localparam pNVZ  = 27;      // Set N and V flags from M[7:6], and Z = ~|(A & M)
localparam pNVZC = 28;      // Set N, V, Z, and C from ALU

//  PSW Bit Masks

localparam pPSW_C = 1;
localparam pPSW_Z = 2;
localparam pPSW_I = 4;
localparam pPSW_D = 8;
localparam pPSW_B = 16;
localparam pPSW_M = 32;
localparam pPSW_V = 64;
localparam pPSW_N = 128;

localparam pPSW_NZ   = (pPSW_N | pPSW_Z);
localparam pPSW_NZC  = (pPSW_N | pPSW_Z | pPSW_C);
localparam pPSW_NVZ  = (pPSW_N | pPSW_V | pPSW_Z);
localparam pPSW_NVZC = (pPSW_N | pPSW_V | pPSW_Z | pPSW_C);

///////////////////////////////////////////////////////////////////////////////

reg  Rst;
reg  Clk;
// Execute Enable
reg  En;
// ALU
reg  [3:0] Op;      // ALU Operation Select
reg  [1:0] QSel;    // ALU Q Bus Select
reg  RSel;          // ALU R Bus Select
reg  Sub;           // ALU AU Operation
reg  CSel;          // ALU AU Carry In Select
reg  [2:0] WSel;    // Register Write Select
reg  [2:0] OSel;    // ALU Output Select
reg  [4:0] CCSel;   // Condition Code Select
reg  [7:0] M;       // Memory Operand - OP1
wire [7:0] Out;     // ALU Output Bus
wire Valid;   
// Condition Code
wire CC_Out;
// Stack
reg  [1:0] StkOp;
wire [7:0] StkPtr;
// Index Registers
wire [7:0] X;
wire [7:0] Y;
// Processor Status Word
wire [7:0] P;

wire [8:0] ALU;
wire [7:0] A;
wire [7:0] S;

// Instantiate the Unit Under Test (UUT)
M65C02_ALU  uut (
                .Rst(Rst), 
                .Clk(Clk), 
                .En(En), 
                .Op(Op),
                .QSel(QSel),
                .RSel(RSel),
                .Sub(Sub),
                .CSel(CSel),
                .WSel(WSel), 
                .OSel(OSel), 
                .CCSel(CCSel), 
                .M(M), 
                .Out(Out),
                .Valid(Valid),
                .CC_Out(CC_Out), 
                .X(X), 
                .Y(Y), 
                .StkOp(StkOp), 
                .StkPtr(StkPtr), 
                .P(P), 
                .ALU(ALU), 
                .A(A), 
                .S(S)
            );

///////////////////////////////////////////////////////////////////////////////

initial begin
    // Initialize Inputs
    Rst   = 1;
    Clk   = 1;
    En    = 0;
    Op    = 0;
    QSel  = 0;
    RSel  = 0;
    Sub   = 0;
    CSel  = 0;
    WSel  = 0;
    OSel  = 0;
    CCSel = 0;
    M     = 0;
    StkOp = 0;

    // Wait 100 ns for global reset to finish
    #101 Rst = 0;
    @(posedge Clk) #1;
    
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
    
    if((A==0) && (X==0) && (Y==0) && (S==0) && (P==(pPSW_M | pPSW_I)))
        $display("Reset Initialization Complete: Registers Initialized");
    else begin
        $display("Reset Initialization Complete: Registers Not Initialized");
        $stop;
    end
    
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

    // Initial Check - Load Registers: A, X, Y, S, P
    
    $display("Start - Register Load Tests");

    // LDA #255, PLA
    En = 1;
    Op = pNOP; QSel = pNOP; RSel = pNOP; Sub = pNOP; CSel = pNOP;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNZ;
    M = 255;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((A!=255) || ((P&(pPSW_NZ))!=(pPSW_N))) begin
        $display("Error: A Register Load Test Failed");
        $stop;
    end

    // LDX #255, PLX
    En = 1;
    Op = pNOP; QSel = pNOP; RSel = pNOP; Sub = pNOP; CSel = pNOP;
    WSel = pSel_X; OSel = pNOP;
    CCSel = pNZ;
    M = 255;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((X!=255) || ((P&(pPSW_NZ))!=(pPSW_N))) begin
        $display("Error: X Register Load Test Failed");
        $stop;
    end

    // LDY #255, PLY
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_Y; OSel = pNOP;
    CCSel = pNZ;
    M = 255;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((Y!=255) || ((P&(pPSW_NZ))!=(pPSW_N))) begin
        $display("Error: Y Register Load Test Failed");
        $stop;
    end

    // TXS
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_S; OSel = pSel_X;
    CCSel = pNOP;
    M = 0;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if(S!=255) begin
        $display("Error: S Register Load Test Failed");
        $stop;
    end

    // LDA #1
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNZ;
    M = 1;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((A!=1) || ((P&(pPSW_NZ))!=(0))) begin
        $display("Error: A Register Load Test Failed");
        $stop;
    end

    // TAX
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_X; OSel = pSel_A;
    CCSel = pNZ;
    M = 0;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((X!=1) || ((P&(pPSW_NZ))!=(0))) begin
        $display("Error: TAX Test Failed");
        $stop;
    end

    // LDA #2
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNZ;
    M = 2;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((A!=1) && ((P&(pPSW_NZ))!=(0))) begin
        $display("Error: A Register Load Test Failed");
        $stop;
    end

    // TAY
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_Y; OSel = pSel_A;
    CCSel = pNZ;
    M = 0;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((Y!=2) || ((P&(pPSW_NZ))!=(0))) begin
        $display("Error: TAY Test Failed");
        $stop;
    end

    // LDA #255
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNZ;
    M = 255;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((A!=255) || ((P&(pPSW_NZ))!=(pPSW_N))) begin
        $display("Error: A Register Load Test Failed");
        $stop;
    end

    // TYA
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_A; OSel = pSel_Y;
    CCSel = pNZ;
    M = 0;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((A!=2) || ((P&(pPSW_NZ))!=(0))) begin
        $display("Error: TYA Test Failed");
        $stop;
    end

    // TSX
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_X; OSel = pSel_S;
    CCSel = pNZ;
    M = 0;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((X!=255) || ((P&(pPSW_NZ))!=(pPSW_N))) begin
        $display("Error: TSX Test Failed");
        $stop;
    end

    // TYA
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_A; OSel = pSel_Y;
    CCSel = pNZ;
    M = 0;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((A!=2) || ((P&(pPSW_NZ))!=(0))) begin
        $display("Error: TYA Test Failed");
        $stop;
    end

    // TXA
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_A; OSel = pSel_X;
    CCSel = pNZ;
    M = 0;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((A!=255) || ((P&(pPSW_NZ))!=(pPSW_N))) begin
        $display("Error: TXA Test Failed");
        $stop;
    end

    // TAY
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_Y; OSel = pSel_A;
    CCSel = pNZ;
    M = 0;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((Y!=255) || ((P&(pPSW_NZ))!=(pPSW_N))) begin
        $display("Error: TAY Test Failed");
        $stop;
    end

    // PLP
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_P; OSel = pNOP;
    CCSel = pNOP;
    M = 0;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if(P!=pPSW_M) begin
        $display("Error: P Register Load Test Failed");
        $stop;
    end

    // STZ
    En = 0;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pNOP; OSel = pSel_Z;
    CCSel = pNOP;
    M = 255;
    @(posedge Clk) #1 En = 0;
    if(Out!=0) begin
        $display("Error: STZ Test Failed");
        $stop;
    end
    
    if((A==255)&&(X==255)&&(Y==255)&&(S==255)&&(P&pPSW_M)&&(Out==0)&&(M==255))
        $display("End - Register Load Tests: Pass");
    else
        $display("End - Register Load Tests: Error");

    // End of Test
    
    @(negedge Valid);
    En = 0;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pNOP; OSel = pNOP; 
    CCSel = pNOP; 
    M = 255;
    @(posedge Clk) #1;

//    $stop;
    
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

    // Test Logic Unit
    
    $display("Start - Logic Unit Tests");
    
    // LDA #55
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_A; OSel = pNOP; 
    CCSel = pNZ; 
    M = 85;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((A!=85) || ((P&(pPSW_NZ))!=(0))) begin
        $display("Error: A Register Load Test Failed");
        $stop;
    end
    
    // ORA #AA
    En = 1;
    Op = pALU_ORA; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_A; OSel = pNOP; 
    CCSel = pNZ; 
    M = 170;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((A!=255) || ((P&(pPSW_NZ))!=(pPSW_N))) begin
        $display("Error: ORA Test Failed");
        $stop;
    end
    
    // EOR #AA
    En = 1; 
    Op = pALU_EOR; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_A; OSel = pNOP; 
    CCSel = pNZ; 
    M = 170;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((A!=85) || ((P&(pPSW_NZ))!=(0))) begin
        $display("Error: EOR Test Failed");
        $stop;
    end

    // AND #AA
    En = 1; Op = pALU_AND; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_A; OSel = pNOP; 
    CCSel = pNZ; 
    M = 170;
    @(posedge Clk) #1.01 En = 0;
//    @(posedge Valid);
    if((A!=0) || ((P&(pPSW_NZ))!=(pPSW_Z))) begin
        $display("Error: AND Test Failed");
        $stop;
    end

    // End of Test

    @(negedge Valid);
    En = 0;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pNOP; OSel = pNOP; 
    CCSel = pNOP; 
    M = 255;
    @(posedge Clk) #1;

    $display("End - Logic Unit Test: Pass");
//    $stop;
    
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

    // Start Arithmetic Unit Test
    
    $display("Start Arithmetic Unit Tests");
    
    // LDA #128
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_A; OSel = pNOP; 
    CCSel = pNZ;
    M = 128;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((A!=128) || ((P&(pPSW_NZ))!=(pPSW_N))) begin
        $display("Error: A Register Load Test Failed");
        $stop;
    end
    
    // ADC #127
    En = 1;
    Op = pALU_ADC; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNVZC;
    M = 127;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((A!=255) || ((P&(pPSW_NVZC))!=(pPSW_N))) begin
        $display("Error: ADC Test #1 Failed");
        $stop;
    end
    
    // ADC #1
    En = 1;
    Op = pALU_ADC; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNVZC;
    M = 1;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((A!=0) || ((P&(pPSW_NVZC))!=(pPSW_Z | pPSW_C))) begin
        $display("Error: ADC Test #2 Failed");
        $stop;
    end

    // ADC #127, since CS, effectively a +128, which results in MI, VS, NE, CC
    En = 1;
    Op = pALU_ADC; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNVZC;
    M = 127;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((A!=128) || ((P&(pPSW_NVZC))!=(pPSW_N | pPSW_V))) begin
        $display("Error: ADC Test #3 Failed");
        $stop;
    end

    // ADC #255, M = -1, which results in PL, VS, NE, CS
    En = 1;
    Op = pALU_ADC; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNVZC;
    M = 255;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((A!=127) || ((P&(pPSW_NVZC))!=(pPSW_V | pPSW_C))) begin
        $display("Error: ADC Test #4 Failed");
        $stop;
    end
    
    //  A = 127, P = VC;
    
    // SBC #1, since CS, M = -1, which results in PL, VC, NE, CS
    En = 1;
    Op = pALU_SBC; QSel = 0; RSel = 0; Sub = 1; CSel = 0;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNVZC;
    M = 1;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((A!=126) || ((P&(pPSW_NVZC))!=(pPSW_C))) begin
        $display("Error: SBC Test #1 Failed");
        $stop;
    end

    // SBC #126, since CS, M = -126, which results in PL, VC, EQ, CS
    En = 1;
    Op = pALU_SBC; QSel = 0; RSel = 0; Sub = 1; CSel = 0;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNVZC;
    M = 126;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((A!=0) || ((P&(pPSW_NVZC))!=(pPSW_Z | pPSW_C))) begin
        $display("Error: SBC Test #2 Failed");
        $stop;
    end

    // SBC #128, since CS, M = -128, which results in MI, VS, NE, CC
    En = 1;
    Op = pALU_SBC; QSel = 0; RSel = 0; Sub = 1; CSel = 0;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNVZC;
    M = 128;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((A!=128) || ((P&(pPSW_NVZC))!=(pPSW_N | pPSW_V))) begin
        $display("Error: SBC Test #3 Failed");
        $stop;
    end

    // SBC #0, since CC, M = -1, which results in PL, VS, NE, CS
    En = 1;
    Op = pALU_SBC; QSel = 0; RSel = 0; Sub = 1; CSel = 0;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNVZC;
    M = 0;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((A!=127) || ((P&(pPSW_NVZC))!=(pPSW_V | pPSW_C))) begin
        $display("Error: SBC Test #4 Failed");
        $stop;
    end

    // SBC #127, since CS, M = -127, which results in PL, VC, EQ, CS
    En = 1;
    Op = pALU_SBC; QSel = 0; RSel = 0; Sub = 1; CSel = 0;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNVZC;
    M = 127;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((A!=0) || ((P&(pPSW_NVZC))!=(pPSW_Z | pPSW_C))) begin
        $display("Error: SBC Test #5 Failed");
        $stop;
    end

    // SBC #1, since CS, M = -1, which results in MI, VC, NE, CC
    En = 1;
    Op = pALU_SBC; QSel = 0; RSel = 0; Sub = 1; CSel = 0;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNVZC;
    M = 1;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((A!=255) || ((P&(pPSW_NVZC))!=(pPSW_N))) begin
        $display("Error: SBC Test #5 Failed");
        $stop;
    end

    // SBC #0, since CC, M = -1, which results in MI, VC, NE, CS
    En = 1;
    Op = pALU_SBC; QSel = 0; RSel = 0; Sub = 1; CSel = 0;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNVZC;
    M = 0;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((A!=254) || ((P&(pPSW_NVZC))!=(pPSW_N | pPSW_C))) begin
        $display("Error: SBC Test #6 Failed");
        $stop;
    end

    // SBC #126, since CS, M = -126, which results in MI, VC, NE, CS
    En = 1;
    Op = pALU_SBC; QSel = 0; RSel = 0; Sub = 1; CSel = 0;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNVZC;
    M = 126;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((A!=128) || ((P&(pPSW_NVZC))!=(pPSW_N | pPSW_C))) begin
        $display("Error: SBC Test #7 Failed");
        $stop;
    end

    // SBC #128, since CS, M = -128, which results in PL, VS, EQ, CS
    En = 1;
    Op = pALU_SBC; QSel = 0; RSel = 0; Sub = 1; CSel = 0;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNVZC;
    M = 128;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((A!=0) || ((P&(pPSW_NVZC))!=(pPSW_Z | pPSW_C))) begin
        $display("Error: SBC Test #7 Failed");
        $stop;
    end
    
    // TAX
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_X; OSel = pSel_A;
    CCSel = pNZ;
    M = 0;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((X!=0) || ((P&(pPSW_NZ))!=(pPSW_Z))) begin
        $display("Error: CLR X Failed");
        $stop;
    end

    // TAY
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_Y; OSel = pSel_A;
    CCSel = pNZ;
    M = 0;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((Y!=0) || ((P&(pPSW_NZ))!=(pPSW_Z))) begin
        $display("Error: CLR Y Failed");
        $stop;
    end

    // DEC A, since A == 0, A <= -1, and MI, VC, NE, CC
    En = 1;
    Op = pALU_DEC; QSel = 0; RSel = 1; Sub = 1; CSel = 1;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNZC;
    M = 0;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((A!=255) || ((P&(pPSW_NZC))!=(pPSW_N))) begin
        $display("Error: DEC A Test #1 Failed");
        $stop;
    end
    
    // INC A, since A == -1, A <= 0, and PL, VC, EQ, CS
    En = 1;
    Op = pALU_INC; QSel = 0; RSel = 1; Sub = 0; CSel = 1;
    WSel = pSel_A; OSel = pNOP;
    CCSel = pNZC;
    M = 0;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((A!=0) || ((P&(pPSW_NZC))!=(pPSW_Z | pPSW_C))) begin
        $display("Error: INC A Test #1 Failed");
        $stop;
    end

    // DEX, since X == 0, X <= -1, and MI, VC, NE, CC
    En = 1;
    Op = pALU_DEC; QSel = 2; RSel = 1; Sub = 1; CSel = 1;
    WSel = pSel_X; OSel = pNOP;
    CCSel = pNZC;
    M = 0;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((X!=255) || ((P&(pPSW_NZC))!=(pPSW_N))) begin
        $display("Error: DEX Test #1 Failed");
        $stop;
    end
    
    // INX since X == -1, X <= 0, and PL, VC, EQ, CS
    En = 1;
    Op = pALU_INC; QSel = 2; RSel = 1; Sub = 0; CSel = 1;
    WSel = pSel_X; OSel = pNOP;
    CCSel = pNZC;
    M = 0;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((X!=0) || ((P&(pPSW_NZC))!=(pPSW_Z | pPSW_C))) begin
        $display("Error: INX Test #1 Failed");
        $stop;
    end

    // DEY, since Y == 0, Y <= -1, and MI, VC, NE, CC
    En = 1;
    Op = pALU_DEC; QSel = 3; RSel = 1; Sub = 1; CSel = 1;
    WSel = pSel_Y; OSel = pNOP;
    CCSel = pNZC;
    M = 0;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((Y!=255) || ((P&(pPSW_NZC))!=(pPSW_N))) begin
        $display("Error: DEY Test #1 Failed");
        $stop;
    end
    
    // INY since Y == -1, Y <= 0, and PL, VC, EQ, CS
    En = 1;
    Op = pALU_INC; QSel = 3; RSel = 1; Sub = 0; CSel = 1;
    WSel = pSel_Y; OSel = pNOP;
    CCSel = pNZC;
    M = 0;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((A!=0) || ((P&(pPSW_NZC))!=(pPSW_Z | pPSW_C))) begin
        $display("Error: INY Test #1 Failed");
        $stop;
    end

    // DEC M, since M == 0, M <= -1, and MI, VC, NE, CC
    En = 1;
    Op = pALU_DEC; QSel = 1; RSel = 1; Sub = 1; CSel = 1;
    WSel = pSel_M; OSel = pNOP;
    CCSel = pNZC;
    M = 0;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((Out!=255) || ((P&(pPSW_NZC))!=(pPSW_N))) begin
        $display("Error: DEC M Test Failed");
        $stop;
    end
    
    // INC M, since M == -1, M <= 0, and PL, VC, EQ, CS
    En = 1;
    Op = pALU_INC; QSel = 1; RSel = 1; Sub = 0; CSel = 1;
    WSel = pSel_M; OSel = pNOP;
    CCSel = pNZC;
    M = 255;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((Out!=0) || ((P&(pPSW_NZC))!=(pPSW_Z | pPSW_C))) begin
        $display("Error: INC M Test Failed");
        $stop;
    end

    // CMP #1 Out <= 255, and MI, VC, NE, CC
    En = 1;
    Op = pALU_CMP; QSel = 0; RSel = 0; Sub = 1; CSel = 1;
    WSel = pSel_M; OSel = pSel_A;
    CCSel = pNZC;
    M = 1;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((Out!=255) || ((P&(pPSW_NZC))!=(pPSW_N))) begin
        $display("Error: CMP #1 Test Failed");
        $stop;
    end

    // CMP #0, Out <= 0, and MI, VC, NE, CS
    En = 1;
    Op = pALU_CMP; QSel = 0; RSel = 0; Sub = 1; CSel = 1;
    WSel = pSel_M; OSel = pSel_A;
    CCSel = pNZC;
    M = 0;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((Out!=0) || ((P&(pPSW_NZC))!=(pPSW_Z | pPSW_C))) begin
        $display("Error: CMP #0 Test Failed");
        $stop;
    end
    
    // CMP #-1, Out <= 1, and PL, VC, NE, CC
    En = 1;
    Op = pALU_CMP; QSel = 0; RSel = 0; Sub = 1; CSel = 1;
    WSel = pSel_M; OSel = pSel_A;
    CCSel = pNZC;
    M = 255;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((Out!=1) || ((P&(pPSW_NZC))!=(0))) begin
        $display("Error: CMP #-1 Test Failed");
        $stop;
    end

    // CPX #2 Out <= -2, and MI, VC, NE, CC
    En = 1;
    Op = pALU_CMP; QSel = 2; RSel = 0; Sub = 1; CSel = 1; 
    WSel = pSel_M; OSel = pSel_X;
    CCSel = pNZC;
    M = 2;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((Out!=254) || ((P&(pPSW_NZC))!=(pPSW_N))) begin
        $display("Error: CPX #2 Test Failed");
        $stop;
    end

    // CPX #0, Out <= 0, and MI, VC, NE, CS
    En = 1;
    Op = pALU_CMP; QSel = 2; RSel = 0; Sub = 1; CSel = 1;
    WSel = pSel_M; OSel = pSel_X;
    CCSel = pNZC; 
    M = 0;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((Out!=0) || ((P&(pPSW_NZC))!=(pPSW_Z | pPSW_C))) begin
        $display("Error: CPX #0 Test Failed");
        $stop;
    end
    
    // CPX #-2, Out <= 2, and PL, VC, NE, CC
    En = 1;
    Op = pALU_CMP; QSel = 3; RSel = 0; Sub = 1; CSel = 1;
    WSel = pSel_M; OSel = pSel_X;
    CCSel = pNZC;
    M = 254;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((Out!=2) || ((P&(pPSW_NZC))!=(0))) begin
        $display("Error: CPX #-2 Test Failed");
        $stop;
    end

    // CPY #3 Out <= 255, and MI, VC, NE, CC
    En = 1;
    Op = pALU_CMP; QSel = 3; RSel = 0; Sub = 1; CSel = 1;
    WSel = pSel_M; OSel = pSel_Y;
    CCSel = pNZC;
    M = 3;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((Out!=253) || ((P&(pPSW_NZC))!=(pPSW_N))) begin
        $display("Error: CPY #3 Test Failed");
        $stop;
    end

    // CPY #0, Out <= 0, and MI, VC, NE, CS
    En = 1; 
    Op = pALU_CMP; QSel = 3; RSel = 0; Sub = 1; CSel = 1; 
    WSel = pSel_M; OSel = pSel_Y; 
    CCSel = pNZC; 
    M = 0;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((Out!=0) || ((P&(pPSW_NZC))!=(pPSW_Z | pPSW_C))) begin
        $display("Error: CPY #0 Test Failed");
        $stop;
    end
    
    // CPY #-3, Out <= 1, and PL, VC, NE, CC
    En = 1; 
    Op = pALU_CMP; QSel = 3; RSel = 0; Sub = 1; CSel = 1; 
    WSel = pSel_M; OSel = pSel_Y; 
    CCSel = pNZC; M = 253;
    @(posedge Clk) #1 En = 0;
    @(posedge Valid);
    if((Out!=3) || ((P&(pPSW_NZC))!=(0))) begin
        $display("Error: CPY #-3 Test Failed");
        $stop;
    end

    // End of Test

    @(negedge Valid);
    En = 0;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pNOP; OSel = pNOP; 
    CCSel = pNOP; 
    M = 255;
    @(posedge Clk) #1;

    $display("End - Arithmetic Unit Test: Pass");
//    $stop;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

    // Shift Unit Tests

    $display("Start - Shift Unit Tests");
    
    // LDA #128
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_A; OSel = pNOP; 
    CCSel = pNZ; 
    M = 128;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((A!=128) || ((P&(pPSW_NZ))!=(pPSW_N))) begin
        $display("Error: A Register Load Test Failed");
        $stop;
    end    
    
    // ASL A
    En = 1; 
    Op = pALU_ASL; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_A; OSel = pNOP; 
    CCSel = pNZC; 
    M = 0;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((A!=0) || ((P&(pPSW_NZC))!=(pPSW_Z | pPSW_C))) begin
        $display("Error: ASL A Test Failed");
        $stop;
    end    
    
    // ASL M
    En = 1; Op = pALU_ASL; QSel = 1; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_M; OSel = pNOP; 
    CCSel = pNZC; 
    M = 85;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((Out!=170) || ((P&(pPSW_NZC))!=(pPSW_N))) begin
        $display("Error: ASL M Test Failed");
        @(negedge Valid);
        $stop;
    end    
    
    // LDA #85
    En = 1; Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_A; OSel = pNOP; 
    CCSel = pNZ; 
    M = 85;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((A!=85) || ((P&(pPSW_NZ))!=(0))) begin
        $display("Error: A Register Load Test Failed");
        $stop;
    end    
    
    // LSR A
    En = 1; Op = pALU_LSR; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_A; OSel = pNOP; 
    CCSel = pNZC; 
    M = 0;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((A!=42) || ((P&(pPSW_NZC))!=(pPSW_C))) begin
        $display("Error: LSR A Test Failed");
        $stop;
    end    
    
    // LSR M
    En = 1; Op = pALU_LSR; QSel = 1; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_M; OSel = pNOP; 
    CCSel = pNZC; 
    M = 170;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((Out!=85) || ((P&(pPSW_NZC))!=(0))) begin
        $display("Error: LSR M Test Failed");
        $stop;
    end    
    
    // ROL A
    En = 1; Op = pALU_ROL; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_A; OSel = pNOP; 
    CCSel = pNZC; 
    M = 0;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((A!=84) || ((P&(pPSW_NZC))!=(0))) begin
        $display("Error: ROL A Test Failed");
        $stop;
    end    
    
    // ROL M -- Asynchronous implementation mixing back into the output the C
    //          at the lsb, but doesn't affect the external register or PSW
    En = 1; 
    Op = pALU_ROL; QSel = 1; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_M; OSel = pNOP; 
    CCSel = pNZC; 
    M = 170;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((Out!=84) || ((P&(pPSW_NZC))!=(pPSW_C))) begin
        $display("Error: ROL M Test Failed");
        $stop;
    end
    
    // ROR A
    En = 1; 
    Op = pALU_ROR; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_A; OSel = pNOP; 
    CCSel = pNZC; 
    M = 0;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((A!=170) || ((P&(pPSW_NZC))!=(pPSW_N))) begin
        $display("Error: ROR A Test Failed");
        $stop;
    end    
    
    // ROR M -- Asynchronous implementation mixing back into the output the C
    //          at the msb, but doesn't affect the external register or PSW
    En = 1; 
    Op = pALU_ROR; QSel = 1; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_M; OSel = pNOP; 
    CCSel = pNZC; 
    M = 191;
    @(posedge Clk) #1.1 En = 0;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((Out!=95) || ((P&(pPSW_NZC))!=(pPSW_C))) begin
        $display("Error: ROR M Test Failed");
        $stop;
    end    
    
    // End of Test

    @(negedge Valid);
    En = 0;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pNOP; OSel = pNOP; 
    CCSel = pNOP; 
    M = 255;
    @(posedge Clk) #1;

    $display("End - Shift Unit Tests: Pass");
//    $stop;
    
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

    // Bit Test Unit Tests

    $display("Start - Bit Test Unit Tests");
    
    // LDA #63
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_A; OSel = pNOP; 
    CCSel = pNZ; 
    M = 63;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((A!=63) || ((P&(pPSW_NZ))!=(0))) begin
        $display("Error: A Register Load Test Failed");
        $stop;
    end    
    
    // BIT M
    En = 1; 
    Op = pALU_BIT; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_M; OSel = pNOP; 
    CCSel = pNVZ; 
    M = 192;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((Out!=0) || ((P&(pPSW_NVZ))!=(pPSW_N | pPSW_V | pPSW_Z))) begin
        $display("Error: BIT M Test Failed");
        $stop;
    end    
    
    // BIT #192 -- check that {N,V} are unchanged from previous result
    En = 1; 
    Op = pALU_BIT; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_M; OSel = pNOP; 
    CCSel = pZ; 
    M = 0;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((Out!=0) || ((P&(pPSW_NVZ))!=(pPSW_N | pPSW_V | pPSW_Z))) begin
        $display("Error: BIT #imm Test Failed");
        $stop;
    end        
 
    // TRB #255 -- Z flag test is ~|(A & M) rather that ~|ALU
    En = 1; 
    Op = pALU_TRB; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_M; OSel = pNOP; 
    CCSel = pZ; 
    M = 255;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((Out!=192) || ((P&(pPSW_Z))!=(0))) begin
        $display("Error: TRB #imm Test Failed");
        $stop;
    end        
 
    // TSB #192 -- Z flag set because test is ~|(A & M) rather that ~|ALU
    En = 1; 
    Op = pALU_TSB; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_M; OSel = pNOP; 
    CCSel = pZ; 
    M = 192;
    @(posedge Clk) #1.1 En = 0;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if((Out!=255) || ((P&(pPSW_Z))!=(pPSW_Z))) begin
        $display("Error: TSB #imm Test Failed");
        $stop;
    end        
 
    // End of Test

    @(negedge Valid);
    En = 0;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pNOP; OSel = pNOP; 
    CCSel = pNOP; 
    M = 255;
    @(posedge Clk) #1;

    $display("End - Bit Test Unit Tests: Pass");
//    $stop;
    
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

    // Condition Code Tests

    $display("Start - Condition Code Tests");
    
    // PLP
    En = 1; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_P; OSel = pNOP; 
    CCSel = pNOP; 
    M = 255;
    @(posedge Clk) #1.1 En = 0;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if(P!=255) begin
        $display("Error: P Register Load Failed");
        $stop;
    end    
    @(negedge Valid);   // Complete Load Operation
    
    $display("   Start - Test Condition Codes");
    
    // BCC
    En = 0; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pNOP; OSel = pNOP; 
    CCSel = pCC; 
    M = 8;
    @(posedge Clk) #1 En = 0;
    @(negedge Clk);
    if(CC_Out!=0) begin
        $display("Error: Carry Clear Test Failed");
        $stop;
    end
    @(posedge Clk) #1;  // Realign test sequence

    // BCS
    En = 0; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pNOP; OSel = pNOP; 
    CCSel = pCS; 
    M = 8;
    @(posedge Clk) #1 En = 0;
    @(negedge Clk);
    if(CC_Out!=1) begin
        $display("Error: Carry Set Test Failed");
        $stop;
    end    
    @(posedge Clk) #1;  // Realign test sequence

    // BNE
    En = 0; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pNOP; OSel = pNOP; 
    CCSel = pNE; 
    M = 8;
    @(posedge Clk) #1 En = 0;
    @(negedge Clk);
    if(CC_Out!=0) begin
        $display("Error: Z Clear Test Failed");
        $stop;
    end
    @(posedge Clk) #1;  // Realign test sequence

    // BEQ
    En = 0; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pNOP; OSel = pNOP; 
    CCSel = pEQ; 
    M = 8;
    @(posedge Clk) #1 En = 0;
    @(negedge Clk);
    if(CC_Out!=1) begin
        $display("Error: Z Set Test Failed");
        $stop;
    end
    @(posedge Clk) #1;  // Realign test sequence

    // BVC
    En = 0; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pNOP; OSel = pNOP; 
    CCSel = pVC; 
    M = 8;
    @(posedge Clk) #1 En = 0;
    @(negedge Clk);
    if(CC_Out!=0) begin
        $display("Error: V Clear Test Failed");
        $stop;
    end
    @(posedge Clk) #1;  // Realign test sequence

    // BVS
    En = 0; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pNOP; OSel = pNOP; 
    CCSel = pVS; 
    M = 8;
    @(posedge Clk) #1 En = 0;
    @(negedge Clk);
    if(CC_Out!=1) begin
        $display("Error: V Set Test Failed");
        $stop;
    end
    @(posedge Clk) #1;  // Realign test sequence

    // BPL
    En = 0; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pNOP; OSel = pNOP; 
    CCSel = pPL; 
    M = 8;
    @(posedge Clk) #1 En = 0;
    @(negedge Clk);
    if(CC_Out!=0) begin
        $display("Error: N Clear Test Failed");
        $stop;
    end
    @(posedge Clk) #1;  // Realign test sequence

    // BMI
    En = 0; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pNOP; OSel = pNOP; 
    CCSel = pMI; 
    M = 8;
    @(posedge Clk) #1 En = 0;
    @(negedge Clk);
    if(CC_Out!=1) begin
        $display("Error: N Set Test Failed");
        $stop;
    end
    @(posedge Clk) #1;  // Realign test sequence

    $display("   End - Test Condition Codes");
    
    // PLP
    En = 1; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_P; OSel = pNOP; 
    CCSel = pNOP; 
    M = 64;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if(P!=96) begin
        $display("Error: P Register Load Failed");
        $stop;
    end    

    $display("   Start - Set/Clr Condition Codes");
    
    // CLV
    En = 1; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_M; OSel = pNOP; 
    CCSel = pCLV; 
    M = 16;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if(P!=32) begin
        $display("Error: CLV Test Failed");
        $stop;
    end
    
    // SEC
    En = 1; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_M; OSel = pNOP; 
    CCSel = pSEC; 
    M = 16;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if(P!=33) begin
        $display("Error: SEC Test Failed");
        $stop;
    end    

    // CLC
    En = 1; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_M; OSel = pNOP; 
    CCSel = pCLC; 
    M = 16;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if(P!=32) begin
        $display("Error: CLC Test Failed");
        $stop;
    end
    
    // SEI
    En = 1; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_M; OSel = pNOP; 
    CCSel = pSEI; 
    M = 16;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if(P!=36) begin
        $display("Error: SEI Test Failed");
        $stop;
    end    

    // CLI
    En = 1; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_M; OSel = pNOP; 
    CCSel = pCLI; 
    M = 16;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if(P!=32) begin
        $display("Error: CLI Test Failed");
        $stop;
    end
    
    // SED
    En = 1; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_M; OSel = pNOP; 
    CCSel = pSED; 
    M = 16;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if(P!=40) begin
        $display("Error: SED Test Failed");
        $stop;
    end    

    // CLD
    En = 1; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_M; OSel = pNOP; 
    CCSel = pCLD; 
    M = 16;
    @(posedge Clk) #1.1;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if(P!=32) begin
        $display("Error: CLD Test Failed");
        $stop;
    end
    
    // BRK
    En = 1; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_M; OSel = pNOP; 
    CCSel = pBRK; 
    M = 16;
    @(posedge Clk) #1.1 En = 0;
//    @(posedge Clk) #1 En = 0;
//    @(posedge Valid);
    if(P!=48) begin
        $display("Error: Set B Test Failed");
        $stop;
    end    

    $display("   End - Set/Clr Condition Codes");
    
    // End of Test

    @(negedge Valid);
    En = 0;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pNOP; OSel = pNOP; 
    CCSel = pNOP; 
    M = 255;
    @(posedge Clk) #1;

    $display("End - Condition Code Tests: Pass");
//    $stop;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

    // Stack Push/Pull Tests

    $display("Start - Stack Push/Pull Tests");
    
    // Push
    StkOp = 2;  // Push
    En = 1; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pSel_M; OSel = pNOP; 
    CCSel = pNOP; 
    M = 192;
    @(posedge Clk) #1.1 En = 0;
    StkOp = 0;
//    @(posedge Valid);
    if(StkPtr==255) begin
        if(S!=254) begin
            $display("Error: Stack Push Test Failed");
            $stop;
        end
    end else begin
        $display("Error: Stack Push Test Failed");
        $stop;    
    end
    
    // Pull
    StkOp = 3;  // Pull
    En = 1;
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0;
    WSel = pSel_M; OSel = pNOP;
    CCSel = pNOP;
    M = 192;
    @(posedge Clk) #1.1 En = 0;
    StkOp = 0;
//    @(posedge Valid);
    if(StkPtr==255) begin
        if(S!=255) begin
            $display("Error: Stack Pull Test Failed");
            $stop;
        end
    end else begin
        $display("Error: Stack Pull Test Failed");
        $stop;    
    end

    // NOP
    @(negedge Valid);
    En = 0; 
    Op = pNOP; QSel = 0; RSel = 0; Sub = 0; CSel = 0; 
    WSel = pNOP; OSel = pNOP; 
    CCSel = pNOP; 
    M = 0;
    @(posedge Clk) #1 En = 0;

    $display("End - Stack Push/Pull Tests: Pass");

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

    $display("End - ALU Tests: Pass");

end

///////////////////////////////////////////////////////////////////////////////
    
always #5 Clk = ~Clk;

///////////////////////////////////////////////////////////////////////////////
      
endmodule

