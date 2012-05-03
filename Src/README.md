M65C02 Processor Core Source Files
==================================

Copyright (C) 2012, Michael A. Morris <morrisma@mchsi.com>.
All Rights Reserved.

Released under LGPL.

Organization
------------

The source files are provided in subdirectories:

    M65C02-Test-Programs
    Memory-Images
    Microprogram-Sources
    RTL
    Settings
    
The contents of each of the subdirectories is provided below.

The M65C02 test programs as assembler programs. Two test programs are provided.
The first program was a simple program used to test the operation of jumps, branches,
stack operations, and register transfers. With this test program, a major part
of the microprogram was tested and verified.

The second test program is a more complete program. All instructions, i.e. all 256
opcodes, are tested using the second program. The operation of the interrupt logic
and the automatic wait state inserted during decimal (BCD) mode addition and subtraction
(ADC/SBC) are also tested with the second test program. It is not a comprehensive
diagnostics program. Examination of the simulation output was used to test the
operation of the M65C02's instructions. However, the second test program does contain
some self-checks, and those were used to speed the process of testing each instruction
and each addressing mode.

The M65C02 is a microprogrammed implementation. There are two microprogram memories
used. The first, M65C02_Decoder_ROM, provides the control of the ALU during the
execute phase. The second, M65C02_uPgm_ROM, provides the control of the core. It
implements each addressing mode, deals with interrupts and BRK. Both microprogram
ROM implement an instruction decoder. When the instruction is present on the input
data bus, it is captured into the instruction register, IR, but it is simultaneously
applied to the address bus of the two microprogram ROMs.

In the Decoder ROM, the opcode is applied in a normal fashion, so the Decoder ROM
is organized linearly. In the uPgm ROM, the opcode is applied to the address bus
with the opcode's nibbles swapped. Thus, the uPgm ROM is best thought of a organized
by the rows in the opcode matrix of the M65C02.

There are three memory images files provided in the corresponding subdirectory.
One is for the test program, and the other two are for the microprogram ROMs. The
microprogram ROMs are implemented using Block RAMs.

The RTL source files are provided along with a user constraint file (UCF) that was
used during development to optimize the implementation times of the core. The UCF
does provide the PERIOD constraint used during development to judge whether the
operating speed objective would be met by the M65C02. The LOCing of the pins was
done to aid the implementation tools, and is not reflective of any implementation
constraints inherent in the M65C02 core logic.

The project, synthesis, and implementation settings were captured in a TCL file.
That file allows the duplication of the exact settings used to synthesize and implement
it in a Spartan-3AN FPGA.

M65C02-Test-Programs
--------------------

    M65C02_Tst2.a65         - Kingswood A65 assembler source code test program
        M65C02.bin          - M65C02_Tst2.a65 binary output of the Kingswood assembler
        M65C02.txt          - M65C02_Tst2.a65 ASCII hexadecimal output of bin2txt.exe
    M65C02_Tst.A65          - First test program: Jumps, Branch, stack ops, register transfers

Memory-Images
-------------

    M65C02_Decoder_ROM.coe  - M65C02 core microprogram ALU control fields
    M65C02_uPgm_V3.coe      - M65C02 core microprogram (Addressing mode control)
    M65C02_Tst2.txt         - Memory initialization file for M65C02 test program

Microprogram-Sources
--------------------
    
    M65C02_Decoder_ROM.txt      - M65C02 core microprogram ALU control fields
        M65C02_Decoder_ROM.out  - Listing file
    M65C02_uPgm_V3.txt          - M65C02 core microprogram (Addressing mode control)
        M65C02_uPgm_V3.out      - Listing file

RTL
-------------

The implementation of the core provided consists of five Verilog source files:

    M65C02_Core.v               - Top level module
        M65C02_MPC.v            - Microprogram Controller (Fairchild F9408 MPC)
        M65C02_ALU.v            - M65C02 ALU module
            M65C02_BIN.v        - M65C02 Binary Mode Adder module
            M65C02_BCD.v        - M65C02 Decimal Mode Adder module
    M65C02.ucf                  - User Constraints File: period and pin LOCs

Settings
-------------

    M65C02.tcl              - Project settings file
    
Status
------

All files are current.