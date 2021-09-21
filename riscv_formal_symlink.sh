#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo "You neet to input the path for the RISC-V Formal Verification Framework"
	exit 1
fi

RVFI_PATH="$1"
if [ ! -d "$RVFI_PATH" ]; then
	echo "$RVFI_PATH does not exist."
	exit 1
fi

RVFI_CORES_PATH=$RVFI_PATH/cores
if [ ! -d "$RVFI_CORES_PATH" ]; then
	echo "$RVFI_CORES_PATH does not exist."
	exit 1
fi

LOCAL_RVFI_PATH=$PWD/src/rvfi
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
