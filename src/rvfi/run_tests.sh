#!/usr/bin/env bash

rm -rf checks
python3 ../../checks/genchecks.py && \
make -C checks -j$(nproc)
