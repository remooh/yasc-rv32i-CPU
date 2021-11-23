#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo "You need to input the hex file"
	exit 1
fi

hexfile="$1"
if [ ! -e "$hexfile" ]; then
	echo "$hexfile does not exist."
	exit 1
fi

if [ -e ram_byte3.hex ]; then
    rm ram_byte3.hex
fi
if [ -e ram_byte2.hex ]; then
    rm ram_byte2.hex
fi
if [ -e ram_byte1.hex ]; then
    rm ram_byte1.hex
fi
if [ -e ram_byte0.hex ]; then
    rm ram_byte0.hex
fi

while read line; do
    echo ${line:0:2} >> ram_byte3.hex
    echo ${line:2:2} >> ram_byte2.hex
    echo ${line:4:2} >> ram_byte1.hex
    echo ${line:6:2} >> ram_byte0.hex
done < $hexfile