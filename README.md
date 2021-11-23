# Yet Another Single Cycle RV32I CPU
![](https://img.shields.io/badge/RISC--V%20Formal-PASS-brightgreen])

A verilog implementation of a simple single-cycle CPU that supports the RISC-V RV32I instruction set. The CPU was verified using the [RISC-V Formal Verification Framework](https://github.com/SymbioticEDA/riscv-formal).

## Table of Contents

- [My Single Cycle RV32I CPU](#my-single-cycle-rv32i-cpu)
  * [Table of Contents](#table-of-contents)
  * [Microarchitecture Overview](#microarchitecture-overview)
  * [Implemented Instructions](#implemented-instructions)
  * [Project Structure](#project-structure)
  * [Running the RISC-V Formal Tests](#running-the-risc-v-formal-tests)
  * [Running the Testbench](#running-the-testbench)

## Microarchitecture Overview
![High Level Microarchitecture Overview](https://raw.githubusercontent.com/Remooh/yasc-rv32i-CPU/master/docs/architecture_overview.png)

The Microarchitecture high level overview is shown above, with the datapath shown in black and the control lines in blue. It follows the Harvard Memory model, with separate buses for data and instruction memories. The instruction cycle is divided in 3 steps: the first step is responsible for fetching the instruction and decoding it, the second step is responsible for the execution of the arithmetic and logic operations and memory access, and the final step is responsible for the write-back.

## Implemented Instructions

| Instruction Type | Instruction                                                                                                    |
|------------------|----------------------------------------------------------------------------------------------------------------|
| **R-Type**       | `add`, `sub`, `slt`, `sltu`, `xor`, `or`, `and`, `sll`, `srl`, `sra`                                           |
| **I-Type**       | `addi`, `slti`, `sltiu`, `xori`, `ori`, `andi`, `slli`, `srli`, `srai`, `lb`, `lh`, `lw`, `lbu`, `lhu`, `jalr` |
| **S-Type**       | `sw`, `sb`, `sh`                                                                                               |
| **B-Type**       | `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`                                                                     |
| **U-Type**       | `auipc`, `lui`                                                                                                 |
| **J-Type**       | `jal`                                                                                                          |

## Project Structure

* **[asm/](https://github.com/Remooh/yasc-rv32i-CPU/tree/master/asm) -**
Assembly code
* **[docs/](https://github.com/Remooh/yasc-rv32i-CPU/tree/master/docs) -**
Documents and images
* **[riscv-formal/](https://github.com/Remooh/riscv-formal) -**
Git submodule containing the [RISC-V Formal Verification Framework](https://github.com/Remooh/riscv-formal)
* **[src/](https://github.com/Remooh/yasc-rv32i-CPU/tree/master/src) -**
Source for the project components
    * **[src/memory/](https://github.com/Remooh/yasc-rv32i-CPU/tree/master/src/memory) -**
    A memory implementation for the CPU in which the data and instructions are stored in the same address space but accessed individually ([Brief Overview](https://github.com/Remooh/yasc-rv32i-CPU/tree/master/src/memory)).
    * **[src/rvfi/](https://github.com/Remooh/yasc-rv32i-CPU/tree/master/src/rvfi) -**
    Integration of the CPU core with the [RISC-V Formal Verification Framework](https://github.com/Remooh/riscv-formal)
    * **[src/rv32i_cpu/](https://github.com/Remooh/yasc-rv32i-CPU/tree/master/src/rv32i_cpu) -**
    CPU core implementation ([Brief Overview](https://github.com/Remooh/yasc-rv32i-CPU/tree/master/src/rv32i_cpu))
    * **[src/testbench/](https://github.com/Remooh/yasc-rv32i-CPU/tree/master/src/testbench) -**
    Testbench

## Running the RISC-V Formal Tests

1. Clone this repo and initialize the submodules:
```bash
git clone --recursive https://github.com/Remooh/yasc-rv32i-CPU.git
cd yasc-rv32i-CPU/
```
2. Create the symlinks to add the CPU core and integration to the RISC-V Formal project. (as of now the framework doesn't support verifying cores outside the expected path).
```bash
./riscv_formal_symlink.sh riscv-formal/
```
3. Install the prerequisites to run the [RISC-V Formal Verification Framework](https://github.com/Remooh/riscv-formal). The instructions can be seen [here](https://github.com/Remooh/riscv-formal/blob/master/docs/quickstart.md).
4. Go to `riscv-formal/cores/rv32i_cpu/` and run:
```bash
./run_tests.sh
```
5. Check the test results in `./riscv-formal/cores/rv32i_cpu/checks/`. In the case of a failed test, [`GTKWave`](http://gtkwave.sourceforge.net/) can be used to display the counter example trace with:
```bash
# $FAILED_TEST is the failed test directory name relative to the checks directory
gtkwave checks/$FAILED_TEST/engine_0/trace.vcd
```

## Running the Testbench

As of now, the testbench instantiates the CPU core in [`src/rv32i_cpu/`](https://github.com/Remooh/yasc-rv32i-CPU/tree/master/src/rv32i_cpu) and the dual port RAM that stores instructions and data in [`src/memory/`](https://github.com/Remooh/yasc-rv32i-CPU/tree/master/src/memory) to run a simple bubble sort program (the source for it is in [`asm/bubblesort.s`](https://github.com/Remooh/yasc-rv32i-CPU/blob/master/asm/bubblesort.s)). The dual port RAM is initialized with the contents of [`src/memory/program.hex`](https://github.com/Remooh/yasc-rv32i-CPU/blob/master/src/memory/program.hex), which has the bubble sort program at the address `0x0` and the random values to be sorted at the address `0x1000`. At the end of the testbench execution, the contents of the memory are dumped in the file `memorydump.hex` and the simulation traces in `rv32i_cpu_tb.vcd`.
To run the testbench check the following steps:

1. Install [`Icarus Verilog`](http://iverilog.icarus.com/), [`GTKWave`](http://gtkwave.sourceforge.net/) and its dependencies.
2. We need to prepare the memory, converting the contents of [`src/memory/program.hex`](https://github.com/Remooh/yasc-rv32i-CPU/blob/master/src/memory/program.hex) to the format required by the dual port ram, for this go to [`src/memory/`](https://github.com/Remooh/yasc-rv32i-CPU/tree/master/src/memory) and run:
```bash
./split_hex.sh program.hex
```
2. To run the simulation, go to [`src/testbench/`](https://github.com/Remooh/yasc-rv32i-CPU/tree/master/src/testbench) and run:
```bash
./rv32i_cpu_tb.sh
```
4. After the simulation finishes, you can check the memory contents dumped in the file `memorydump.hex` (can be opened with a text editor) and analyze the simulation traces with [`GTKWave`](http://gtkwave.sourceforge.net/):
```bash
gtkwave rv32i_cpu_tb.vcd
```