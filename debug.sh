#!/bin/bash -e
GDB=/opt/toolchains/gcc-arm-none-eabi-9-2019-q4-major/bin/arm-none-eabi-gdb

$GDB --command=./source/config/gdb.ini -tui ./build-stm32/src_stdperiph/stm32f4xx-cmake-template.elf