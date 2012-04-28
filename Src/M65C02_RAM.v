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
// Create Date:     22:35:57 02/04/2012 
// Design Name:     WDC W65C02 Microprocessor Re-Implementation
// Module Name:     M65C02_RAM 
// Project Name:    C:\XProjects\ISE10.1i\MAM6502 
// Target Devices:  Generic SRAM-base FPGA 
// Tool versions:   Xilinx ISE10.1i SP3
//
// Description: 
//
// Dependencies: 
//
// Revision: 
//
//  0.00    12B04   MAM     Initial File Creation
//
// Additional Comments: 
//
///////////////////////////////////////////////////////////////////////////////

module M65C02_RAM #(
    parameter pAddrSize = 10,
    parameter pDataSize = 8,
    parameter pFileName = "M65C02_RAM.txt"
)(
    input   Clk,
    
    input   WE,
    input   [(pAddrSize - 1):0] AI,
    input   [(pDataSize - 1):0] DI,
    output  [(pDataSize - 1):0] DO
);

localparam pRAM_Max = ((2**pAddrSize) - 1);

reg     [(pDataSize - 1):0] RAM [pRAM_Max:0];

initial
    $readmemh(pFileName, RAM, 0, pRAM_Max);

always @(posedge Clk)
begin
    if(WE)
        RAM[AI] <= #1 DI;
end

assign DO = RAM[AI];

endmodule
