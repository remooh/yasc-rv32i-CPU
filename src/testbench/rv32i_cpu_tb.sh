#!/usr/bin/env bash
iverilog -o my_design rv32i_cpu_tb.v && \
vvp my_design && \
rm my_design
