////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012-2013 by Michael A. Morris, dba M. A. Morris & Associates
//
//  All rights reserved. The source code contained herein is publicly released
//  under the terms and conditions of the GNU Lesser Public License. No part of
//  this source code may be reproduced or transmitted in any form or by any
//  means, electronic or mechanical, including photocopying, recording, or any
//  information storage and retrieval system in violation of the license under
//  which the source code is released.
//
//  The source code contained herein is free; it may be redistributed and/or 
//  modified in accordance with the terms of the GNU Lesser General Public
//  License as published by the Free Software Foundation; either version 2.1 of
//  the GNU Lesser General Public License, or any later version.
//
//  The source code contained herein is freely released WITHOUT ANY WARRANTY;
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

////////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates
// Engineer:        Michael A. Morris
//
// Create Date:     15:34:45 02/22/2013
// Design Name:     M65C02
// Module Name:     C:/XProjects/ISE10.1i/M65C02/tb_M65C02.v
// Project Name:    M65C02
// Target Device:   Xilinx Spartan-3A FPGA - XC3S50A-4VQ100
// Tool versions:   ISE 10.1i SP3  
//
// Description: 
//
// Verilog Test Fixture created by ISE for module: M65C02
//
// Dependencies:
// 
// Revision:
//
//  0.01    13B22   MAM     File Created
//
//  1.00    14B24   MAM     Initial release
//
//  1.10    13B26   MAM     Changed to support M65C02 with internal 2kB Boot ROM    
//
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_M65C02;

parameter pRAM_AddrWidth = 11;

// UUT Signal Declarations

reg     nRst;
tri1    nRstO;

reg     ClkIn;

wire    Phi1O;
wire    Phi2O;

tri1    nSO;
tri1    nNMI;
tri1    nIRQ;
tri1    nVP;

reg     BE_In;
tri1    Rdy;
tri0    Sync;
tri1    nML;
wire    nWait;

tri1    [3:0] nCE;
tri1    RnW;
tri1    nOE;
tri1    nWr;
tri1    [ 3:0] XA;
tri1    [15:0] A;
tri1    [ 7:0] DB;

tri1    nSel;
tri1    SCk;
tri1    MOSI;
reg     MISO;

//  Define simulation variables

integer i = 0;

reg     Sim_nSO, Sim_nNMI, Sim_nIRQ;

// Instantiate the Unit Under Test (UUT)

M65C02  #(
            .pBootROM_File("M65C02_Tst3.txt")
        ) uut (
            .nRst(nRst),
            .nRstO(nRstO),
            
            .ClkIn(ClkIn),
            
            .Phi1O(Phi1O), 
            .Phi2O(Phi2O), 

            .nSO(nSO), 
            .nNMI(nNMI), 
            .nIRQ(nIRQ), 
            .nVP(nVP), 

            .BE_In(BE_In), 
            .Sync(Sync), 
            .nML(nML), 

            .nCE(nCE), 
            .RnW(RnW), 
            .nWr(nWr), 
            .nOE(nOE), 
            .Rdy(Rdy), 
            .XA(XA), 
            .A(A), 
            .DB(DB),

            .nWP_In(1'b0),
            
            .nWait(nWait), 
        
            .nSel(nSel), 
            .SCk(SCk), 
            .MOSI(MOSI), 
            .MISO(MISO)
        );

////  Instantiate Boot/Monitor ROM Module
//
//wire    [7:0] ROM_DO;
//reg     ROM_WE;
//
//M65C02_RAM  #(
//                .pAddrSize(pRAM_AddrWidth),
//                .pDataSize(8),
//                .pFileName("M65C02_Tst3.txt")
//            ) ROM (
//                .Clk(~Phi2O),
////                .Ext(1'b1),     // 4 cycle memory
////                .ZP(1'b0),
////                .Ext(1'b0),     // 2 cycle memory
////                .ZP(1'b0),
//                .Ext(1'b0),   // 1 cycle memory
//                .ZP(1'b1),
//                .WE(ROM_WE),
//                .AI(A[(pRAM_AddrWidth - 1):0]),
//                .DI(DB),
//                .DO(ROM_DO)
//            );

//  Instantiate RAM Module

wire    [7:0] RAM_DO;
reg     RAM_WE;

M65C02_RAM  #(
                .pAddrSize(pRAM_AddrWidth),
                .pDataSize(8),
                .pFileName("M65C02_RAM.txt")
            ) RAM (
                .Clk(~Phi2O),
//                .Ext(1'b1),     // 4 cycle memory
//                .ZP(1'b0),
//                .Ext(1'b0),     // 2 cycle memory
//                .ZP(1'b0),
                .Ext(1'b0),   // 1 cycle memory
                .ZP(1'b1),
                .WE(RAM_WE),
                .AI(A[(pRAM_AddrWidth - 1):0]),
                .DI(DB),
                .DO(RAM_DO)
            );

initial begin
    // Initialize Inputs
    nRst     = 0;
    ClkIn    = 1;
    Sim_nSO  = 0;
    Sim_nNMI = 0;
    Sim_nIRQ = 0;
    BE_In    = 1;
    //Rdy      = 1;
    MISO     = 1;

    // Wait 100 ns for global reset to finish
    #101 nRst = 1;
    
    // Add stimulus here
    
    // Test WAI w/ IRQ_Mask set
    
    @(negedge nWait);
    for(i = 0; i < 4; i = i + 1) @(posedge Phi1O);
    Sim_nIRQ = 1;
    @(posedge nWait);
    @(posedge Phi1O) Sim_nIRQ = 0;
    
    while(1) begin
        @(posedge Phi1O);
        if(A == 16'hF800) begin
            @(posedge Phi1O);
            @(posedge Phi1O);
            $display("End of Simulation - Looping to Start detected/n");
            $stop;
        end
    end
           
end

////////////////////////////////////////////////////////////////////////////////
//
//  Clocks
//

always #27.127 ClkIn = ~ClkIn;
//always #20 ClkIn = ~ClkIn;

////////////////////////////////////////////////////////////////////////////////
//
//  Test Structures
//

//  Connect ROM/RAM to M65C02 memory bus

//always @(*) ROM_WE <= Phi2O &  A[15] & ~nWr;

always @(*) RAM_WE <= Phi2O & ~A[15] & ~nWr;

//assign DB = ((~nOE) ? ((A[15]) ? ROM_DO : RAM_DO) : {8{1'bZ}});
assign DB = ((~nOE) ? RAM_DO : {8{1'bZ}});

//  Generate Simulate nIRQ signal based on writes by test program to address
//      0xFFF8 (assert nIRQ) or 0xFFF9 (deassert nIRQ)

always @(posedge nWr or negedge nRstO)
begin
    if(~nRstO)
        Sim_nIRQ <= 0;
    else
        Sim_nIRQ <= ((A[15:1] == 15'b1111_1111_1111_100) ? ~A[0] : Sim_nIRQ);
end

//  Drive nSO, nNMI, and nIRQ using simulation controlled signals

assign nSO  = ((Sim_nSO)  ? 0 : 1'bZ);
assign nNMI = ((Sim_nNMI) ? 0 : 1'bZ);
assign nIRQ = ((Sim_nIRQ) ? 0 : 1'bZ);

endmodule

