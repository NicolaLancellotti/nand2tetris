#!/bin/bash

declare -a files=(
  projects/07/MemoryAccess/BasicTest/BasicTest
  projects/07/MemoryAccess/PointerTest/PointerTest
  projects/07/MemoryAccess/StaticTest/StaticTest
  projects/07/StackArithmetic/SimpleAdd/SimpleAdd
  projects/07/StackArithmetic/StackTest/StackTest)

# Generate
for i in ${files[@]}; do
  $(cd programs/vm-translator; swift run VMTranslator ../../$i.vm)
done

# Test
for i in ${files[@]}; do
  ./tools/CPUEmulator.sh $i.tst
done
