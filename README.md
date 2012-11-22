M65C02 Microprocessor Core
=======================

Copyright (C) 2012, Michael A. Morris <morrisma@mchsi.com>.
All Rights Reserved.

Released under LGPL.

General Description
-------------------

This project provides a microprogrammed implementation of the WDC W65C02 
microprocessor.

It is provided as a core. Several external components are required to form a 
functioning processor: (1) memory, (2) interrupt controller, and (3) I/O 
interface buffers. The Verilog testbench provided demonstrates a simple 
configuration for a functioning processor implemented with the M65C02 core: 
M65C02_Core. Currently, the core provided here only executes the original op-
codes of the WDC W65C02 processor, and not the extended instructions of the 
current WDC W65C02S synthesizable core. (In addition to the original W65C02 
instructions, the WDC W65C02S also implements the BBSx, BBRx, SMBx, and RMBx 
instructions introduced by Rockwell in the R65C02, and additional instructions 
introduced by WDC (WAI/STP) in its 65C802/65C816 microprocessors.)

The core handles an interrupt signal, which external logic asserts after it 
processes any interrupts that it services. That is, the core accepts and 
performs the interrupt trap processing, but the external logic must implement 
the type of interrupt (maskable or non-maskable), and provide the vector to 
the core. This implementation is different than the original processor's in 
that an indirect jump through a pre-determined address is not performed by the 
core. The implementation envisioned is that the external interrupt controller 
records the vectors for reset (RST), the non-maskable interrupt (NMI), or the 
maskable interrupt (IRQ) and provides the appropriate vector when requested by 
the core. Although this approach means that the JMP (vector) operation is not 
performed, it is unlikely that a processor emulator, which may require the 
original processor's behaviour, will be used with a modern, FPGA-based 65C02 
core. Further, the approach selected for this core greatly speeds entry into 
the ISR by not performing the vector fetch using JMP (vector) operation, and 
is more consistent with a modern re- implementation. Further, this approach 
can be used to support a vectored interrupt structure with more interrupt 
sources than the original processor implementation supported: IRQ, NMI, and 
RST.

The Release 2.x core now provides a microcycle length controller as an 
integral component of its Microprogram Controller (MPC). The microprogram can 
now inform the external memory controller, on a cycle by cycle basis, of the 
memory cycle type. Logic external to the core can use this output to map the 
memory cycle to whatever memory is appropriate, and to drive the microcycle 
length inputs of the core to extend each microcycle if necessary. Thus, the 
Release 2.x core no longer assumes that the external memory is implemented as 
an asynchronous memory device, and as a result, the core no longer expects 
that the memory will accept an address and return the read data at that 
address in the same cycle. With the built-in microcycle length controller, 
single cycle LUT-based zero page memory, 2 cycle internal block RAM memory, 
and 4 cycle external memory can easily be supported. A Wait input can also be 
used to extend, i.e. add wait states, to the 4 cycle microcycles, so a wide 
variety of memories can be easily supported; the only limitation being the 
memories types supported by the user-supplied external memory controller.

The core provides a large number of status and control signals that external 
logic may use. It also provides access to many internal signals such as all of 
the registers, A, X, Y, S, and P. The Mode, RMW, SC, and Done status outputs 
may be used to provide additional signals to external devices. Mode provides 
an indication of the kind of instruction being executed:

    0 - internal/single cycle (INC/DEC A, TAX/TXA, SEI/CLI, etc.),
    1 - memory access (LDA/LDX/LDY, STA/STX/STY/STZ, INC abs, etc.),
    2 - stack access (PHA/PLA, PHX/PLX, PHY/PLY),
    3 - jump/branch (JMP, BRA, Bcc),
    4 - subroutine call (JSR),
    5 - subroutine return (RTS/RTI)
    6 - break (BRK)
    7 - Invalid (all undefined op-codes)

RMW indicates that a read-modify-write instruction will be performed. External
logic can use this signal to lock memory.

SC is used to indicate a single cycle instruction.

Done is asserted during the instruction fetch of the next instruction. In many 
cases, the execution of each instruction is signalled by Done on the same 
cycle that the next instruction op-code is being read from memory. Thus, the 
M65C02 core demonstrates pipelined behaviour, and as a result, tends to 
execute many W65C02 instructions in fewer clock cycles.

The external bus transaction is signalled by IO_Op. IO_Op signals data memory 
writes, data memory reads, and instruction memory reads. Therefore, external 
logic may implement separate data and instruction memories and potentially 
double the amount of memory that an implementation may access. Using Mode it 
is also possible for stack memory to be separate from data and instruction 
memory.

Implementation
--------------

The implementation of the core provided consists of five Verilog source files 
and several memory initialization files:

    M65C02_Core.v           - Top level module
        M65C02_MPCv3.v      - M65C02 MPC with microcycle length controller
        M65C02_AddrGen.v    - M65C02 Address Generator module
        M65C02_ALU.v        - M65C02 ALU module
            M65C02_BIN.v    - M65C02 Binary Mode Adder module
            M65C02_BCD.v    - M65C02 Decimal Mode Adder module
    
    M65C02_Decoder_ROM.coe  - M65C02 core microprogram ALU control fields
    M65C02_uPgm_V3a.coe     - M65C02 core microprogram (sequence control)

    M65C02.ucf              - User Constraints File: period and pin LOCs
    M65C02.tcl              - Project settings file
    
    tb_M65C02_Core.v        - Completed core testbench with test RAM
    
    M65C02.txt              - Memory configuration file of M65C02 test program
        M65C02_Tst2.a65     - Kingswood A65 assembler source code test program

    tb_M65C02_ALU.v         - testbench for the ALU module
    tb_M65C02_BCD.v         - testbench for the BCD adder module

Synthesis
---------

The objective for the core is to synthesize such that the FF-FF speed is 100 MHz
or higher in a Xilinx XC3S200AN-5FGG256 FPGA using Xilinx ISE 10.1i SP3. In that
regard, the core provided meets and exceeds that objective. Using the settings
provided in the M65C02.tcl file, ISE 10.1i tool implements the design and
reports that the 9.091 ns period (110 MHz) constraint is satisfied.

The ISE 10.1i SP3 implementation results are as follows:

    Number of Slice FFs:            196
    Number of 4-input LUTs:         693
    Number of Occupied Slices:      420
    Total Number of 4-input LUTs:   705 (12 used as route-throughs)

    Number of BUFGMUXs:             1
    Number of RAMB16BWEs            2   (M65C02_Decoder_ROM, M65C02_uPgm_V3a)

    Best Case Achievable:           9.043 ns (0.048 ns Setup, 0.864 ns Hold)

Status
------

Design and verification is complete.

Release Notes
-------------

###Release 1

Release 1 of the M65C02 had an issue in that addressing wrapping of zero page 
addressing was not properly implemented. Unlike the W65C02 and MOS6502, the 
M65C02 synthesizable core implemented the addressing modes, but allowed page 
boundaries to be crossed for all addressing modes. This initial behavior is 
more like that of the WDC 65C802/816 microprocessors in native mode. With this 
release, Release 2, the zero page addressing modes of the M65C02 core behave 
like those of the WDC W65C02.

Following Release 1, a couple of quick patches were made to the zero page 
addressing, but these failed to address all of the issues. Release 2 uses the 
same basic next address generation logic, except that it now allows the 
microcode to control when addresses are computed modulo 256. With this change, 
all outstanding issues with respect to zero page addressing have been 
corrected.

###Release 2

Release 2 has reworked the Microprogram Controller (MPC) to include a 
microcycle length controller directly. With this new MPC, it is expected that 
it will be easier to adapt the core to use LUT RAM for page 0 (data page) and 
page 1 (stack page), and to attach a external memory controller with variable 
length access cycles. The microcycle length controller allows 1, 2, or 4 cycle 
microcycles. Neither the 1 and 2 cycle microcyles support wait state 
insertion, but the 4 cycle microcycle allows the insertion of wait states. 
With this architecture, LUT and internal Block RAMs can be used to provide 
high speed operation. The 4 cycle external memory microcycle should easily 
allow the core to support asynchronous or synchronous external memory. Release 
1 allowed variable length microcycles, but the address-based mechanism 
implemented was difficult to use in practice. Release 1 targeted a single 
cycle memory like that provided by the distributed LUT RAMs of the target 
FPGAs. The approach used in Release 2 should make it much easier to adapt the 
M65C02 core.

Release 2.1 has modified the core to export signals to an external memory
controller that would allow the memory controller to drive the core logic with
the required microcycle length value for the next microcycle. The test bench for
the core is running in parallel with the original Release 1 (with zero page
adressing corrected) core (M65C02_Base.v) so that a self-checking configuration
is achieved between the two cores and the common test program. Release 2.1 also
includes a modified memory model module, M65C02_RAM,v, that supports all three
types of memory that is expected to be used with the core: LUT (page 0), BRAM
(page 1 and internal program/data memory), and external pipelined SynchRAM.

Release 2.2 has been tested using microcycles of 1, 2, or 4 cycles in length. 
During testing, some old issues returned when multi-cycle microcycles were 
used. With single cycle microcycles there were no problems with either of the 
two cores: M65C02_Core.v or M65C02_Base.v. For example, with 2 and 4 cycle 
microcycles, the modification of the PSW before the first instruction of the 
ISR was found to be taking place several microcycles before it should. This 
issue was tracked down to the fact that the microprogram ROMs and the PSW 
update logic were not being qualified by the internal Rdy signal, or end-of-
microcycle. In the single cycle microcycle case, previous corrections applied 
to address this issue still worked, but the single cycle solutions applied did 
not generalize to the multi-cycle cases. Thus, several modules were modified 
so that ISR, BCD, and zero page addressing modes now behave correctly for 
single and multi-cycle microcycles.
