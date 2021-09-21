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
    Sample implementation for the data memory and instruction memory
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
5. Check the test results in `./riscv-formal/cores/rv32i_cpu/checks/`. In the case of a failed test [`GTKWave`](http://gtkwave.sourceforge.net/) can be used to display the counter example trace with:
```bash
# $FAILED_TEST is the failed test directory name relative to the checks directory
gtkwave checks/$FAILED_TEST/engine_0/trace.vcd
```

## Running the Testbench

As of now the testbench instantiates the CPU core in `src/rv32i_cpu/` and the data and instruction memories in `src/memory/` to run a simple bubble sort program (the source for it is in `asm/bubblesort.s`). The instruction memory is initialized with the bubble sort program and the data memory is initialized with random values.
To run the testbench check the following steps:

1. Install [`Icarus Verilog`](http://iverilog.icarus.com/), [`GTKWave`](http://gtkwave.sourceforge.net/) and its dependencies.
2. Go to `src/testbench/` and run:
```bash
./rv32i_cpu_tb.sh
```
3. Type `finish` to exit the simulation prompt after it finishes.
4. Analyse the simulation traces with [`GTKWave`](http://gtkwave.sourceforge.net/):
```bash
gtkwave rv32i_cpu_tb.vcd
```