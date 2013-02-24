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
// Company:         M. A. Morris & Assoc.
// Engineer:        Michael A. Morris
// 
// Create Date:     12:49:16 11/18/2012 
// Design Name:     WDC W65C02 Microprocessor Re-Implementation
// Module Name:     M65C02.v 
// Project Name:    C:\XProjects\ISE10.1i\M65C02 
// Target Devices:  Generic SRAM-based FPGA 
// Tool versions:   Xilinx ISE10.1i SP3
//
// Description:
//
//  This module provides a synthesizable implementation of a 65C02 micropro-
//  cessor similar to the WDC W65C02S. The original W65C02 implemented a set of
//  enhancements to the MOS6502 microprocessor. Two new addressing modes were
//  added, several existing instructions were rounded out using the new address-
//  ing modes, and some additional instructions were added to fill in holes pre-
//  in the instruction set of the MOS6502. Rockwell second sourced the W65C02, 
//  and in the process added 4 bit-oriented instructions using 32 opcodes. WDC
//  released the W65816/W65802 16-bit enhancements to the W65C02. Two of the new
//  instructions in these processors, WAI and STP, were combined with the four
//  Rockwell instructions, RMBx/SMBx and BBRx/BBSx, along with the original
//  W65C02's instruction set to realize the W65C02S.
//
//  The M65C02 core is a realization of the W65C02S instruction set. It is not a
//  cycle accurate implementation, and it does not attempt to match the idiosyn-
//  cratic behavior of the W65C02 or the W65C02S with respect to unused opcodes.
//  In the M65C02 core, all unused opcodes are realized as single byte, single
//  cycle NOPs.
//
//  This module demonstrates how to incorporate the M65C02_Core.v logic module
//  into an application-specific implementation. The core logic incorporates
//  most of the logic required for a microprocessor implementation: ALU, regis-
//  ters, address generator, and instruction decode and sequencing. Not included
//  in the core logic are the memory interface, the interrupt handler, the clock
//  generator, and any peripherals.
//
//  This module integrates the M65C02_Core.v module, an external memory inter-
//  face, a simple vectored interrupt controller, and a clock generator. The ob-
//  jective is a module that emulates the external interfaces of a 5C02 proces-
//  sor. The intent is not to develop a W65C02S replacement; an FPGA-based emu-
//  lation of a processor still in production and readily available is not eco-
//  nomically viable, or an objective of this project. (To be economically
//  viable, an FPGA-based implementation of a 65C02 system using the M65C02
//  (or WDC's synthesizable W65C02S) must be more than just a drop-in replace-
//  ment of the microprocessor; it must include on-chip peripherals and addi-
//  tional I/O interfaces, provide extended addressing, higher performance, etc.
//  In other words, it must be more than just a replacement of the inexpensive
//  40-pin/44-pin W65C02S microprocessor.)
//
//  The 6502 memory interface is not particularly well suited for an FPGA-based
//  implementation. FPGA-based implementations prefer to use a single clock, and
//  the 6502 memory interface uses a two phase clocking scheme. Further, for
//  6502-family peripherals which require a clock, the clock needs to be conti-
//  nuous and symmetric. The M65C02 core logic will be overclocked relative to
//  the 6502 memory interface. Thus, the memory interface controller can ensure
//  that the core logic and the output clocks are synchronized and continuous
//  and symmetric. However, this requires that any wait states needed by the ex-
//  ternal memory or peripherals must be inserted as integer multiples of the
//  external memory cycle length. This means that if there are four micro-cycles
//  per external memory cycle, then every requested wait state will add an addi-
//  tional 4 cycles to each microcycle.
//
//  With this configuration, the external memory's access time determines the
//  overall performance of the M65C02. Asynchronous memories are probably the
//  least expensive of any of the high-speed static RAMs currently available.
//  Therefore, the external memory interface provided with the M65C02 will pro-
//  vide support for high-speed asynchronous SRAMs and Flash EPROMs. To provide
//  reasonable price vs. performance, a 25ns access time will be used as the
//  target device speed for RAM. 
//
//  A common interface provided by embedded computers is the asynchronous serial
//  port. To make the interface reliable, the expectation is that the external
//  clock input of the M65C02 will be a provided by a "baud rate" crystal oscil-
//  lator. The frequency expected is the commonly available 18.432 MHz.
//
//  The Tiockp, clock to output time, of a typical FPGA capable of 100 MHz
//  internal operation is: 3.4ns for -5 Spartan-3AN with the IOBs configured for
//  LVTTL operation, 12mA drive, and fast slew rate. The input setup time with
//  input delay, Tiopickd, is: 3.73ns with IOB-DELAY=3. These delays, which sum
//  to 7.13ns, must be added to the RAM's access time to determine the external
//  memory cycle time: 42.13ns for a 35ns access time device.
//
//  If the external 18.432 MHz clock is multiplied by 4 and divided by 4 to set
//  the external memory cycle period, the resulting period would be 54.253ns,
//  which satisfies the 42.13ns requirement with some margin. Therefore, the
//  module will use a DCM whose input frequency is provided by a 18.432 MHz
//  oscillator. The internally the M65C02 will operate at 73.728 MHz in a
//  4 clock per microcycle configuration; the memory controller controls the
//  microcycle length of the M65C02.
//
// Dependencies:    M65C02_Core.v
//                      M65C02_MPCv3.v
//                          M65C02_uPgm_V3a.coe (M65C02_uPgm_V3a.txt)
//                          M65C02_Decoder_ROM.coe (M65C02_Decoder_ROM.txt)
//                      M65C02_AddrGen.v
//                      M65C02_ALU.v
//                          M65C02_Bin.v
//                          M65C02_BCD.v 
//
// Revision: 
//
//  0.00    12B18   MAM     Initial File Creation
//
//  0.01    13B16   MAM     Added DCM/DFS clock generator, refined port list,
//                          and refined internal reset signal generation.
//
//  1.00    13B23   MAM     Completed the integration and testing of the M65C02
//                          implementation as a standalone microprocessor.
//
// Additional Comments:
//
//  With regard to the W65C02S, the M65C02 microprocessor implementation differs
//  in a number of ways:
//
//      1)  The instruction set is emulated, but cycle accuracy was not an
//          objective, and the implementation provided here makes no attempt to
//          to provide instruction cycles times which match those of the W65C02S
//          microprocessor.
//
//          The M65C02 core provides pipelined execution and fetch operations.
//          This feature allows the M65C02 to reduce the number of memory cycles
//          required per instruction. In addition, additional address generation
//          logic for sequential operand fetch, program counter updates, and
//          stack pointer updates allows some complex instructions to reduce the
//          number of memory cycles required by one or two cycles. (Branches all
//          execute in two cycles regardless of whether the branch is taken or
//          not taken.)
//
//      2)  The W65C02S provides capabilities for wait state insertion, external
//          DMA control, and external falling edge-edge setting of the V flag in
//          the processor status word.
//
//          The M65C02 implementation provided here does not support the inser-
//          tion of wait states by external logic. The implementation does sup-
//          port the BE input signal to tri-state the signals of the processor
//          connecting to the bus. The BE_In input port will tri-state all of
//          the M65C02 processor bus signals. Since wait state insertion is not
//          supported, external DMA logic can not stop the M65C02 processor and
//          take control of the bus. The nSO port is provided to reserve a pin
//          for a potential future upgrade of the M65C02 to support the Set
//          Overflow feature found in the W65C02S. The current implementation of
//          the M65C02 core will have to be modified to support this function.
//
//      3)  Like the W65C02S, the M65C02 provides a Vector Pull output pin. The
//          pin, nVP, is asserted by the M65C02 during the two memory cycles in
//          which the IRQ/NMI/BRK/RST vectors are read from ROM/RAM/Registers.
//
//      4)  Unlike the W65C02S, the M65C02 provides four chip enable outputs to
//          simplify the selection of RAM, ROM, SYStem ROM, and I/O devices.
//
//          The current implementation provides a four chip enables: CE[3:0].
//
//          CE[0], RAM chip enable, asserts for a 48kB range: 0x0000-0xBFFF.
//          CE[1], ROM chip enable, asserts for a  8kB range: 0xC000-0xDFFF.
//          CE[2], SYS chip enable, asserts for a  4kB range: 0xE000-0xEFFF.
//          CE[3], IO  chip enable, asserts for a  4kB range: 0xF000-0xFFFF.
//          
//          The M65C02 also makes provisions for extended address outputs,
//          XA[3:0], which are intended to be used with a simple internal MMU to
//          allow mapping of 8kB blocks in a total address space of 4MB.
//
//      5)  The M65C02 implements a bus interface that is not exactly a standard
//          implementation of the two phase 6502 memory interface.
//
//          To address generation logic used to reduce the number of memory
//          cycles required per instruction is combinatorial and in series with
//          the output address lines. The M65C02 registers all I/O signals. The
//          consequence of this implementation detail is that the M65C02's
//          address output is delayed from its internal clock's rising edge by a
//          significant portion of the clock period. A synchronous output is
//          very much desired because it provides consistent clock to output 
//          delay times, and it eliminates the skew in the combinatorial signal
//          paths of the M65C02 core's address generator. Thus, the memory
//          address, which in a typical 6502 is output during Phi1O, is not out-
//          put by the M65C02 until the start of Phi2O.
//
//          The control signals and the output data are are similarly registered
//          and delayed to coincide with the delay in the address. This means
//          that the external memory and I/O devices must be able to operate
//          with signals which are only asserted during Phi2O. The reduced
//          operating margins means that RAMs and IO devices must be able to
//          reliably operate in a window of approximately 20ns.
//
//          To use the M65C02 core in this environment, the M65C02 processor
//          implementation effectively shews the 6502 memory cycle by a quarter
//          of the cycle. There are four states in the M65C02 core's microcycle.
//
//              C1 - Address computation cycle
//              C2 - Output address, data, and control signals
//              C3 - Deassert control, and capture input data
//              C4 - Execute current instruction and decode next instruction 
//
//          In this four cycle process, Phi1O is asserted during C4 and C1, and
//          Phi2O is asserted during C2 and C3. 
//          
//          For SRAMs, it is not difficult to meet the timing requirements im-
//          posed by this modified 6502 memory cycle with an inexpensive device.
//          For ROMs, the modified 6502 memory cycle is difficult to satisfy 
//          with devices suitable for use with a 6502, i.e. NOR Flash devices.
//          The minimum access times that NOR Flash devices provide is 45ns, and
//          the typical device requires access times of 55ns and/or 70ns.
//
//          One objective of the M65C02 is to provide a memory interface solu-
//          tion to which it is easy to connect readily available memory. It is
//          for this reason that the CE logic is included in the implementation.
//          In addition, two control signals, nOE and nWr, are provided so that
//          external logic is not required to combine Phi2O and RnW into output
//          and write enable signals.
//
//          Without implementing a wait state generator, the M65C02 requires
//          some means to support a slow NOR Flash memory devices. To accomplish
//          this without requiring external logic or extremely fast NOR Flash
//          devices, means that some type of internally generated clock stretch
//          logic is required. The M65C02 provides automatic clock stretching
//          logic for the IO chip enable address range. 
//
//          The FPGA clocking resources provide a glitchless clock multiplexer.
//          Using one of these multiplexers, the M65C02 multiplexes the internal
//          system clock between 73.728 MHz ClkFX clock and the 36.864 MHz Clk2X
//          clock. (ClkFX and Clk2X are directly related and generated in phase
//          from the input clock. Clk2X is used as the feedback source for the
//          DCM, and is in phase with ClkFX which is generated by the DFS.)
//
//          These clock changes will be glitch free, and will demonstrate the
//          operation of a clocking resource of the FPGA that is seldom used.
//          But when accessing the 4kB of IO, the frequency and duty cycle of
//          the Phi1O/Phi2O two phase clock will not be held at 18.432 MHz or
//          50%. The clock multiplexer logic stretches the clocks from a nominal
//          period equal to the period of the input clock, or 54.253ns, to a
//          period equal to 1.5x the period of the input clock, or 81.830ns. In
//          the clock multiplexer implemented, the Phi1O pulse width is un-
//          changed, 27.127ns, and the Phi2O pulse width is doubled, 54.253ns.
//
////////////////////////////////////////////////////////////////////////////////

module M65C02 #(
    parameter pStkPtr_Rst  = 8'hFF,         // SP Value after Rst

    parameter pIRQ_Vector = 16'hFFFE,       // IRQ Vector Addrs
    parameter pRst_Vector = 16'hFFFC,       // Reset Vector Addrs
    parameter pNMI_Vector = 16'hFFFA,       // NMI Vector Addrs
    parameter pBrk_Vector = 16'hFFFE,       // Brk Vector Addrs
    
    parameter pInt_Hndlr  = 9'h021,         // Microprogram Interrupt Handler

    parameter pBRK        = 3'b010,         // BRK #imm instruction
    parameter pWAI        = 3'b111,         // WAI Mode

    parameter pNOP        = 8'hEA,          // M65C02 Core NOP instruction

    parameter pROM_AddrWidth = 12,          // System ROM Addres Width

    parameter pM65C02_uPgm = "M65C02_uPgm_V3a.coe",
    parameter pM65C02_IDec = "M65C02_Decoder_ROM.coe",
    parameter pFileName    = "M65C02_Tst3.txt"
)(
    input   nRst,               // System Reset Input
    output  nRstO,              // Internal System Reset Output (OC w/ PU)
    input   ClkIn,              // System Clk Input
    
    output  reg Phi2O,          // Clock Phase 2 Output
    output  reg Phi1O,          // Clock Phase 1 Output - complement of Phi2O
    
    input   nSO,                // Set oVerflow: currently unimplemented

    input   nNMI,               // Non-Maskable Interrupt Request: edge sense
    input   nIRQ,               // Maskable Interrupt Request: level sense
    output  nVP,                // Vector Pull: asserted to indicate ISR taken

    input   BE_In,              // Bus Enable: tri-states address, data, control
    output  Sync,               // Synchronize: asserted during opcode fetch
    output  nML,                // Memory Lock: asserted during RMW instructions

    output  [3:0] nCE,          // Chip Enable for External RAM/ROM Memory
    output  RnW,                // Read/nWrite cycle control output signal
    output  nWr,                // External Asynchronous Bus Write Strobe
    output  nOE,                // External Asynchronous Bus
    inout   Rdy,                // Bus cycle Ready, drive low to extend cycle
    output  [ 3:0] XA,          // Extended Address Output for External Memory
    output  [15:0] A,           // External Memory Address Bus
    inout   [ 7:0] DB,          // External, Bidirectional Data Bus
    
    output  reg nWait,          // Driven low by Wait instruction (ASIC-only)
    
    output  nSel,               // SPI I/F Chip Select
    output  SCk,                // SPI I/F Serial Clock
    output  MOSI,               // SPI I/F Master Out/Slave In Serial Data
    input   MISO                // SPI I/F Master In/Slave Out Serial Data
);

///////////////////////////////////////////////////////////////////////////////
//
//  Declarations
//

wire    ClkFX, Clk2X;           // DCM output multiplexed to drive system Clk
reg     ClkSel;                 // FF used to select Clk drive source

reg     [3:0] DCM_Rst;          // Stretched DCM Reset (see Table 3-6 UG331)
reg     nRst_IFD;               // Input FF for external Reset signal
reg     [3:0] xRst;             // Stretched external reset (Buf_ClkIn)
wire    Rst_M65C02;             // Combination of DCM_Rst and xRst
reg     [3:0] Rst_Dly;          // Stretched internal reset (Buf_ClkIn)
wire    FE_Rst_Dly;             // Falling edge of Rst_Dly (Clk)
reg     Rst;                    // Internal reset (Clk)
reg     OE_nRstO;               // Internal reset output (Buf_ClkIn)

wire    RE_NMI;                 // Output pulse signal from nNMI edge detector
wire    CE_NMI;                 // NMI latch/register clock enable
reg     NMI;                    // NMI latch/register to hold NMI until serviced

reg     nIRQ_IFD, IRQ;          // External maskable interrupt request inputs

wire    Int;                    // Interrupt handler interrupt signal to M65C02
wire    [15:0] Vector;          // Interrupt handler interrupt vector to M65C02

wire    Brk;                    // Decoded M65C02 core instruction mode - BRK

reg     BE_IFD;                 // External Bus Enable input register (IOB)
wire    BE;                     // Internal Bus Enable signal

wire    IRQ_Msk;                // M65C02 core interrupt mask
wire    IntSvc;                 // M65C02 core interrupt service indicator
wire    ISR;                    // M65C02 core signal for signaling vector read
wire    Done;                   // M65C02 core instruction complete/fetch
wire    [2:0] Mode;             // M65C02 core instruction mode
wire    RMW;                    // M65C02 core Read-Modify-Write indicator
wire    [1:0] MC;               // M65C02 core microcycle 
wire    [1:0] IO_Op;            // M65C02 core I/O cycle type
wire    [15:0] AO;              // M65C02 core Address Output
reg     [ 7:0] DI;              // M65C02 core Data Input
wire    [ 7:0] DO;              // M65C02 core Data Output

wire    C1, C2, C3, C4;         // Decoded microcycle states

reg     [1:0] VP;               // Vector read/pull pulse stretcher

reg     Sync_OFD;
reg     nML_OFD;
reg     RnW_OFD;

wire    IO, SYS, ROM, RAM;      // Address decode signals

reg     [ 3:0] nCE_OFD;         // Decoded Chip Enable output (IOB registers)
reg     [ 3:0] XA_OFD;          // Extended Address output (IOB registers)
reg     [15:0] AO_OFD;          // Address Output (IOB registers)

reg     nOE_OFD, nWr_OFD;

reg     [7:0] DO_OFD;

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

//  Implement internal clock generator using DCM and DFS. DCM/DFS multiplies
//  external clock reference by 4.

ClkGen  ClkGen (
            .USER_RST_IN(DCM_Rst[0]),           // DCM Rst generated on FE Lock 

            .CLKIN_IN(ClkIn),                   // ClkIn          = 18.432 MHz
            .CLKIN_IBUFG_OUT(Buf_ClkIn),        // Buffered ClkIn = 18.432 MHz

            .CLKFX_OUT(ClkFX),                  // DCM ClkFX_Out  = 73.728 MHz 

            .CLK0_OUT(),                        // Clk0_Out unused 
            .CLK2X_OUT(Clk2X),                  // Clk2x_Out (FB) = 36.864 MHz 
            
            .LOCKED_OUT(DCM_Locked)             // When 1, DCM Locked 
        );

//  Implement Clock Multiplexer which switches between ClkFX and Clk2X when the
//  memory access cycle selects the I/O bank: 0xF800-0xFFFF.

always @(posedge ClkFX or posedge Rst_M65C02)
begin
    if(Rst_M65C02)
        ClkSel <= #1 0;
    else if(C1 | C3)
        ClkSel <= #1 ((C3) ? 0 : IO);
end

// BUFGMUX: Global Clock Buffer 2-to-1 MUX
// Virtex-II/II-Pro/4/5, Spartan-3/3E/3A
// Xilinx HDL Libraries Guide, version 10.1.2

BUFGMUX ClkMux (
            .O(Clk),            // Clock MUX output
            .I0(ClkFX),         // Clock0 input
            .I1(Clk2X),         // Clock1 input
            .S(ClkSel)          // Clock select input
        );
        
// End of BUFGMUX_inst instantiation
        
//  Detect falling edge of DCM_Locked, and generate DCM reset pulse at least 4
//  ClkIn periods wide if a falling edge is detected. (see Table 3-6 UG331)
        
fedet   FE1 (
            .rst(1'b0),             // No reset required for this circuit 
            .clk(Buf_ClkIn),        // Buffered DCM input Clock
            .din(DCM_Locked),       // DCM Locked signal
            .pls(FE_DCM_Locked)     // Falling Edge of DCM_Locked signal
        );
        
always @(posedge Buf_ClkIn or posedge FE_DCM_Locked)
begin
    if(FE_DCM_Locked)
        DCM_Rst <= #1 4'b1111;
    else
        DCM_Rst <= #1 {1'b0, DCM_Rst[3:1]};
end

//  Synchronize asynchronous external reset, nRst, to internal clock and
//      stretch (extend) by 16 clock cycles after external reset deasserted
//
//  With Spartan 3A(N) FPGA family use synchronous reset for reset operations
//  per synthesis recommendations. so only these FFs will use asynchronous
//  reset, and the remainder of the design will use synchronous reset.

always @(posedge Buf_ClkIn or negedge DCM_Locked)
begin
    if(~DCM_Locked)
        nRst_IFD <= #1 0;
    else
        nRst_IFD <= #1 nRst;
end

always @(posedge Buf_ClkIn or negedge DCM_Locked)
begin
    if(~DCM_Locked)
        xRst <= #1 ~0;
    else
        xRst <= #1 {~nRst_IFD, xRst[2:1]};
end        

assign Rst_M65C02 = ((&{~nRst_IFD, xRst}) | ~DCM_Locked);

always @(posedge Buf_ClkIn or posedge Rst_M65C02)
begin
    if (Rst_M65C02)
        Rst_Dly <= #1 ~0;
    else
        Rst_Dly <= #1 {1'b0, Rst_Dly[3:1]};
end

//  synchronize Rst to DCM/DFS output clock (if DCM Locked)

fedet   FE2 (
            .rst(Rst_M65C02),       
            .clk(Clk),              // System Clock
            .din(|Rst_Dly),         // System Reset Delay
            .pls(FE_Rst_Dly)        // Falling Edge of Rst_Dly
        );

always @(posedge Clk or posedge Rst_M65C02)
begin
    if(Rst_M65C02)
        Rst <= #1 1;
    else if(FE_Rst_Dly)
        Rst <= #1 0;
end

//  Generate Reset output for use by external circuits

always @(posedge Buf_ClkIn or posedge Rst)
begin
    if(Rst)
        OE_nRstO <= #1 1;
    else
        OE_nRstO <= #1 0;
end

assign nRstO = ((OE_nRstO) ? 0 : 1'bZ);

//
//  Process External NMI and maskable IRQ Interrupts
//

//  Perform falling edge detection on the external non-maskable interrupt input

fedet   FE3 (
            .rst(Rst), 
            .clk(Clk), 
            .din(nNMI), 
            .pls(RE_NMI)
        );

//  Capture and hold the rising edge pulse for NMI in NMI FF until serviced by
//      the processor.

assign CE_NMI = (Rst | IntSvc | RE_NMI);
always @(posedge Clk) NMI <= #1 ((CE_NMI) ? RE_NMI : 0);

//  Synchronize external IRQ input to Clk

always @(posedge Clk or posedge Rst) nIRQ_IFD <= #1 ((Rst) ? 1 :  nIRQ);
always @(posedge Clk or posedge Rst) IRQ      <= #1 ((Rst) ? 0 : ~nIRQ_IFD);

assign Brk    = (Mode == pBRK);
assign Int    = (NMI | (~IRQ_Msk & IRQ));
assign Vector = ((Int) ? ((NMI) ? pNMI_Vector
                                : pIRQ_Vector)
                       : ((Brk) ? pBrk_Vector
                                : pRst_Vector));
                       
//  Synchronize BE input to Clk

always @(posedge Clk or posedge Rst) BE_IFD <= #1 ((Rst) ? 0 : BE_In);

assign BE = BE_IFD;

//  Instantiate M65C02 Core

M65C02_Core #(
                .pStkPtr_Rst(pStkPtr_Rst),
                .pInt_Hndlr(pInt_Hndlr),
                .pM65C02_uPgm(pM65C02_uPgm),
                .pM65C02_IDec(pM65C02_IDec)
            ) uP (
                .Rst(Rst), 
                .Clk(Clk),
                
                .IRQ_Msk(IRQ_Msk),
                .xIRQ(IRQ),                
                .Int(Int), 
                .Vector(Vector), 
                .IntSvc(IntSvc),
                .ISR(ISR),

                .Done(Done), 
                .SC(), 
                .Mode(Mode), 
                .RMW(RMW), 
                
                .MC(MC), 
                .MemTyp(),
                .uLen(2'b11),       // Len 4 Cycle 
//                .uLen(2'b1),        // Len 2 Cycle 
//                .uLen(2'b0),        // Len 1 Cycle
                .Wait(1'b0),        // No wait states support at this time 
                .Rdy(),
                
                .IO_Op(IO_Op), 
                .AO(AO), 
                .DI(DI), 
                .DO(DO),
                
                .A(), 
                .X(), 
                .Y(), 
                .S(), 
                .P(), 
                .PC(),
                
                .IR(),
                .OP1(), 
                .OP2()
            );
            
//  Define the Memory Cycle Strobes (1 cycle in width)

assign C1 = (MC == 2);      // First cycle of microcycle
assign C2 = (MC == 3);      // Second cycle of microcyle
assign C3 = (MC == 1);      // Third cycle of microcycle
assign C4 = (MC == 0);      // Fourth cycle of microcycle

//  Assign Phi1O and Phi2O

always @(posedge Clk or posedge Rst_M65C02)
begin
    if(Rst_M65C02)
        {Phi1O, Phi2O} <= #1 2'b01;
    else
        {Phi1O, Phi2O} <= #1 {(C3 | C4), (C1 | C2)};
end

//  Generate Chip Enables

assign IO  = (&AO[15:13] &  AO[12]);
assign SYS = (&AO[15:13] & ~AO[12]);
assign ROM = (&AO[15:14] & ~AO[13]);
assign RAM = ~&AO[15:14];

always @(posedge Clk)
begin
    if(Rst)
        nCE_OFD <= #1 ~0;
    else if(C1)
        nCE_OFD <= #1 {~IO, ~SYS, ~ROM, ~RAM};
end

assign nCE = ((BE) ? nCE_OFD : {4{1'bZ}});

//  Generate Address Output

always @(posedge Clk)
begin
    if(Rst)
        {XA_OFD, AO_OFD} <= #1 {{4{1'b1}}, pRst_Vector};
    else if(C1)
        {XA_OFD, AO_OFD} <= #1 {{4{IO}}, AO};
end

assign {XA, A} = ((BE) ? {XA_OFD, AO_OFD} : {{4{1'bZ}}, {16{1'bZ}}});

//  Generate Vector Pull Output

always @(posedge Clk)
begin
    if(Rst)
        VP <= #1 0;
    else if(C4)
        VP <= #1 ((ISR) ? 2'b11 : {1'b0, VP[1]});
end

assign nVP = ((BE) ? ~VP[0] : 1'bZ);

//  Generate nWait output; assert nRdy input when nWait asserted

always @(posedge Clk or posedge Rst)
begin
    if(Rst)
        nWait <= #1 1;
    else if(C1)
        nWait <= #1 ~(Mode == pWAI);
end

assign Rdy = ((~nWait) ? 0 : 1'bZ);

//  Generate M65C02 Memory Lock Signal

always @(posedge Clk)
begin
    if(Rst)
        nML_OFD <= #1 1;
    else if(C1)
        nML_OFD <= #1 ~RMW;
end

assign nML = ((BE) ? nML_OFD : 1'bZ);

//  Generate Sync Output

always @(posedge Clk)
begin
    if(Rst)
        Sync_OFD <= #1 1;
    else if(C1)
        Sync_OFD <= #1 Done;
end

assign Sync = ((BE) ? Sync_OFD : 1'bZ);

//  Generate M65C02 RnW output

always @(posedge Clk)
begin
    if(Rst)
        RnW_OFD <= #1 1;
    else if(C1)
        RnW_OFD <= #1 ~(IO_Op == 1);
end

assign RnW = ((BE) ? RnW_OFD : 1'bZ);

//  Generate Asynchronous SRAM Read Strobe

always @(posedge Clk) nOE_OFD <= #1 ((Rst | C3) ? 1 
                                                : ((C1) ? ~IO_Op[1] 
                                                        : nOE_OFD));

assign nOE = ((BE) ? nOE_OFD : 1'bZ);

//  Generate Asynchronous SRAM Write Strobe 

always @(posedge Clk) nWr_OFD <= #1 ((Rst | C3) ? 1 
                                                : ((C1) ? ~(IO_Op == 1)
                                                        : nWr_OFD));

assign nWr = ((BE) ? nWr_OFD : 1'bZ);

//  Drive DO out M65C02 module
//      Feed nWR strobe back in as second output enable. Coupled with half cycle
//      shift in the nOE signal, these delays should make it easy to satisfy 
//      bus disable times when write operations follow reads and vice-versa.


always @(posedge Clk or posedge Rst)
begin
    if(Rst)
        DO_OFD <= #1 0;
    else if(C1)
        DO_OFD <= #1 DO;
end

assign DB = ((BE & ~nWr) ? DO_OFD : 8'bZ);

//  Capture Input Data from External Memory
//      Half cycle shift allows more time for RAM/peripheral device to output
//      data. Internal signal paths in the FPGA will operate on the data within
//      half a cycle of Clk. This requires tighter path controls by the map and
//      route tools. DI is distributed to IR, OP1, OP2, uPgm_ROM, and IDec_ROM.

always @(posedge Clk)
begin
    if(Rst)
        DI <= #1 pNOP;
    else if(C3)
        DI <= #1 DB;
end

endmodule
