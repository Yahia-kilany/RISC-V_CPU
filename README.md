# RISC-V Single Cycle CPU

Course: CSCE 3301 – Computer Architecture
Instructor: Dr. Sherif Salama
Date: November 10, 2025

---

## Team Members

- Ouail Slama
- Yahia Kilany

---

## Project Overview

This project implements a RISC-V single-cycle CPU capable of executing a subset of the RV32I instruction set.

---

## Key Features

- Supports R, I, S, B, U, and J instruction formats
- Implements basic arithmetic, logical, load/store, and branch instructions
- Immediate generator for all instruction formats
- Separate instruction and data memory modules
- Byte-, halfword-, and word-addressable data memory
- Branch control unit for conditional jumps
- Load/Store Unit for proper memory alignment and sign extension
- 7-segment display and LED output for debugging and visualization

---

## Assumptions

- All instructions are 32 bits wide and aligned to word boundaries.
- Memory is initialized with valid instruction and data contents.
- No hazards are handled, as the CPU is single-cycle.
- Only a subset of RV32I instructions is supported (no multiplication/division or CSR operations).
- PC starts at address 0x00000000.

---

## Known Issues

- The top module used for FBGA implementation is not correctly configured
- No exception or interrupt handling.
- No support for compressed (RVC) or floating-point instructions.

---

## What Works

- Correct execution of ADD, SUB, AND, OR, XOR, SLL, SRL, SLT, SLTU
- Functional load/store (LB, LH, LW, SB, SH, SW)
- Proper immediate generation for all instruction types
- Working branch logic for BEQ, BNE, BLT, BGE
- Stable integration of all modules (ALU, Control, Register File, Memory, etc.)

---

## What Does Not Work

- System calls, interrupts, and exceptions not implemented
- No support for pipeline or hazard detection
- The top module used for FBGA implementation is not correctly configured

---

## Release Notes

Version 1.0 (Final Submission)

- Added Load/Store Unit for byte-addressable memory
- Fixed syntax errors in ALU, ImmGen, and Shifter
- Updated control unit for extended instruction support
- Connected all datapath modules in CPU.v
- Integrated top-level I/O through top.v
- Verified operation on simulation and limited FPGA testing

=========================================================
End of README
=============
