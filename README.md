MAM65C02 Microprocessor
=======================

Copyright (C) 2012, Michael A. Morris <morrisma@mchsi.com>.
All Rights Reserved.

Released under LGPL.

General Description
-------------------

This project is a project to demonstrate a microprogrammed implementation of the
WDC65C02 microprocessor. It is provided as a core. Several external components
are required to form a functioning processor: (1) memory, (2) interrupt controller,
and (3) I/O interface buffers. The Verilog testbench provided demonstrates
a simple configuration for a functioning processor implemented with the M65C02
core: M65C02_Core. The core provides all the logic to execute the original op-codes
of the W65C02 processor, and not the extended instructions of the current
W65C02S synthesizable core.

The core handles an interrupt signal, which external logic asserts after it processes
any interrupts that it provides. That is, the core accepts and performs
the interrupt trap processing, but the external logic must implement the type of
interrupt (maskable or non-maskable), and provide the vector to the core. This
implementation is different than the original processor's in that an indirect
jump through a predetermined address is not performed by the core. The implementation
envisioned is that the external interrupt controller records the vectors for reset
(RST), the non-maskable interrupt (NMI), or the maskable interrupt (IRQ) and
provides the apropriate vector when requested by the core.

The core assumes that the external memory is implemented as an asynchronous
memory device, and as a result, the core expects that the memory will accept an
address and return the read data at that address in the same cycle. It also
expects that addresses and write data from the core will be accepted in the same
cycle. The core does provide an external transfer acknowledge signal, Ack, that
external logic may use to extend memory cycles.

The core provides a large number of status and control signals that external
logic may use. It also provides access to many internal signals such as all of
the registers, A, X, Y, S, and P. The Mode, RMW, SC, and Done status outputs 
may be used to provide additional signals to external devices. Mode provides an
indication of the kind of instruction being executed:

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
cases, the execution of each instruction is signalled by Done on the same cycle
that the next instruction op-code is being read from memory. Thus, the M65C02
core demonstrates pipelined behaviour, and as a result, tends to execute many
65C02 instructions in fewer clock cycles.

The external bus transaction is signalled by IO_Op. IO_Op signals data memory
writes, data memory reads, and instruction memory reads. Therefore, external
logic may implement separate data and instruction memories and potentially
double the amount of memory that an implementation may access. Using Mode it is
also possible for stack memory to be separate from data and instruction memory.

Implementation
--------------

The implementation of the core provided consists of five Verilog source files
and several memory initialization files:

    M65C02_Core.v           - Top level module
        M65C02_MPC.v        - Microprogram Controller (Fairchild F9408 MPC)
        M65C02_ALU.v        - M65C02 ALU module
            M65C02_BIN.v    - M65C02 Binary Mode Adder module
            M65C02_BCD.v    - M65C02 Decimal Mode Adder module
    
    M65C02_Decoder_ROM.coe  - M65C02 core microprogram ALU control fields
    M65C02_uPgm_V3.coe      - M65C02 core microprogram (Addressing mode control)

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

    Number of Slice FFs:            310
    Number of 4-input LUTs:         746
    Number of Occupied Slices:      480
    Total Number of 4-input LUTs:   755 (9 used as route-throughs)

    Number of BUFGMUXs:             1
    Number of RAMB16BWEs            2   (M65C02_Decoder_ROM, M65C02_uPgm_V3)

    Best Case Achievable:           9.035 ns (0.056 ns Setup, 0.976 ns Hold)

Status
------

Design and verification is complete. User testing is underway. 