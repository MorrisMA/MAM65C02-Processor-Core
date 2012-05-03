M65C02 Processor Core Utilities
===============================

Copyright (C) 2012, Michael A. Morris <morrisma@mchsi.com>.
All Rights Reserved.

Released under LGPL.

General Description
-------------------

This subdirectory provides a utility to convert binary assembler output files into
ASCII hexadecimal memory initialization files as required by Xilinx ISE. 

Usage
-----

The utility bin2txt.exe and its associated source file, bin2txt.c, operate as a
DOS command line utility. It was compiled using the Borland Turbo C/C++ 2.0 compiler.

The utility requires the path and filename of a binary input file and
the path and filename of an output file.

The input file is opened for reading as binary. The output file is opened for writing
as a text (ASCII, single byte character set) file. Data is read from the input file,
vconverted to ASCII Hexadecimal, and written to the output file. Each input byte
is written to the output as two ASCII characters on a single line. Each line is
terminated with a standard newline terminator, "\n".

While reading the input file, a count of the number of bytes processed is kept.
After all input data has been read from the input file and written to the output
file, the output file is padded with 0x00 so that the total number of lines is
equal to a power of two.

Documentation
-------------

If the number of required arguments are not supplied, then before terminating the
utility will print out a prompt to the user that defines the needed arguments.

Status
------

Design and verification is complete.