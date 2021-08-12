#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo "You neet to input the path for the RISC-V Formal Verification Framework"
	exit 1
fi

RVFI_CORES_PATH="$1"cores
LOCAL_RVFI_PATH=$PWD/src/riscv_formal
LOCAL_CORE_PATH=$PWD/src/rv32i_cpu

RVFI_FILE_LIST=$(ls $LOCAL_RVFI_PATH)
mkdir $RVFI_CORES_PATH/rv32i_cpu
for i in $RVFI_FILE_LIST; do
	ln -s $LOCAL_RVFI_PATH/$i $RVFI_CORES_PATH/rv32i_cpu/$i
done || exit 1

CORE_FILE_LIST=$(ls $LOCAL_CORE_PATH)
mkdir $RVFI_CORES_PATH/rv32i_cpu/rv32i_cpu
for i in $CORE_FILE_LIST; do
	ln -s $LOCAL_CORE_PATH/$i $RVFI_CORES_PATH/rv32i_cpu/rv32i_cpu/$i
done || exit 1
