# Dual Port RAM

Here is a brief overview about the memory implementation for the RV32I core.

## dualport_ram.v

The memory implementation for the RV32I core. It consists of a dual port ram addressed by word (32 bits or 4 bytes).
It has a port for data operations and a read only port for instructions, where both can be accessed simultaneously and both occupy the same address space, this way the CPU sees the memory as the Harvard architecture model, but it behaves as the von Neumann architecture model.
The memory needs to be initialized with a hex file containing 4 byte words and with length 4096 by default, unless the parameter `ADDR_WIDTH` is changed, just like [`src/memory/program.hex`](https://github.com/Remooh/yasc-rv32i-CPU/blob/master/src/memory/program.hex). The files for initialization can be generated with the script [split_hex.sh](#split_hexsh).

## program.hex

Contains the memory initialization for the simulation in [`src/testbench/`](https://github.com/Remooh/yasc-rv32i-CPU/tree/master/src/testbench). It consists of the bubble sort program [`asm/bubblesort.s`](https://github.com/Remooh/yasc-rv32i-CPU/blob/master/asm/bubblesort.s) at the address `0x0` (corresponds to the 1st line of the file) and the random values to be sorted at the address `0x1000` (corresponds to the 1024th line of the file as it is addressed by word and not byte).

## split_hex.sh

Script that generates the initialization files for the memory [dualport_ram.v](#dualport_ramv).
It is run as the following, using [`src/memory/program.hex`](https://github.com/Remooh/yasc-rv32i-CPU/blob/master/src/memory/program.hex) as example.
```bash
./split_hex.sh program.hex
```