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

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:07:42 02/04/2012
// Design Name:   M65C02_RAM
// Module Name:   C:/XProjects/ISE10.1i/MAM6502/tb_M65C02_RAM.v
// Project Name:  MAM6502
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: M65C02_RAM
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_M65C02_RAM;

	reg     Rst;
    reg     Clk;

	reg     WE;
	wire    [9:0] AI;
	reg     [7:0] DI;
	wire    [7:0] DO;
    
    //  Simulation Variables
    
    reg     [9:0] Cntr;
    wire    TC_Cntr;

	// Instantiate the Unit Under Test (UUT)
    
M65C02_RAM  #(
                .pAddrSize(10),
                .pDataSize(8),
                .pFileName("M65C02_Tst.txt")
            ) RAM (
                .Clk(Clk),
                .WE(WE),
                .AI(Cntr),
                .DI(DI),
                .DO(DO)
            );

initial begin
    // Initialize Inputs
    Rst = 1;
    Clk = 1;
    WE  = 0;
    DI  = 0;

    // Wait 100 ns for global reset to finish
    #101 Rst = 0;
    
    // Add stimulus here

end

///////////////////////////////////////////////////////////////////////////////
//
//  Clocks

always #5 Clk = ~Clk;

///////////////////////////////////////////////////////////////////////////////

always @(posedge Clk)
begin
    if(Rst | TC_Cntr)
        Cntr = #1 0;
    else
        Cntr = #1 Cntr + 1;
end

assign TC_Cntr = (Cntr == 10'h01F);

assign AI = Cntr; 
      
endmodule

