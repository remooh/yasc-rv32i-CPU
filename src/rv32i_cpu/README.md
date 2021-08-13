# RV32I CPU Core

Here is a brief overview about the RV32I CPU core implementation.

## alu.v

Module containing the implementation for the arithmetic logic unit. 
The supported operations are the following: `addition`, `subtraction`, `or`, `and`, `xor`, `shift left logical`, `shift right logical`, `shift right arithmetic`, `set if less than`, `set if less than unsigned`, `set if equal`.
The operations are defined by an internal signal defined in [defines.v](#definesv)

## control_unit.v

Module containing the implementation for the CPU control unit.
The control signals are based in the instruction fields`opcode`, `funct3` and `funct7` extracted in [decode.v](#decodev). The unit controls the alu operation, the sources for the alu operands, the source for the `rd` register, how the next program counter should be obtained and the type of memory access operation.

## decode.v
Module that is responsible for decoding the instruction.
It simply hardwires each instruction fields to each corresponding position according to the [RISC-V Spec](https://github.com/riscv/riscv-isa-manual/releases/download/Ratified-IMAFDQC/riscv-spec-20191213.pdf) for the RV32I base instruction set. This module also decodes the instruction immediate.

## defines.v

This file contains the definition of all the macros and signals used in the project.

## program_counter.v

Module resposible for managing the program counter.
This module holds the program counter and manages it by calculating the address of the next instruction based on the control signals.

## register_file.v

Module containing the implementation for the CPU register file.
It is basically a 32x32 bits dual port RAM with two output buses for reading that implement `rs1` and `rs2` and a single input bus for writing that implement `rd`.

## rv32i_cpu.v

This is the top level project module, where all the modules above are instantiated and connected.
It contains a few multiplexers/demultiplexers for connecting some signals, the state machine that defines the CPU instruction cycle, and the implementation for the [RISC-V Formal Interface (RVFI)](https://github.com/Remooh/riscv-formal/blob/master/docs/rvfi.md).
