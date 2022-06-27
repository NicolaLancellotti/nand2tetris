#!/bin/bash

declare -a files=(
  projects/08/ProgramFlow/BasicLoop/BasicLoop
  projects/08/ProgramFlow/FibonacciSeries/FibonacciSeries
  projects/08/FunctionCalls/SimpleFunction/SimpleFunction
)

declare -a directories=(
  projects/08/FunctionCalls/FibonacciElement
  projects/08/FunctionCalls/NestedCall
  projects/08/FunctionCalls/StaticsTest
)

# Generate
for i in ${files[@]}; do
  $(cd programs/vm-translator; swift run VMTranslator ../../$i.vm)
done

for i in ${directories[@]}; do
  $(cd programs/vm-translator; swift run VMTranslator ../../$i)
done

# Test
for i in ${files[@]}; do
  ./tools/CPUEmulator.sh $i.tst
done

for i in ${directories[@]}; do
  ./tools/CPUEmulator.sh $i/$(basename $i).tst
done
