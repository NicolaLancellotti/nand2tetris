#!/bin/bash

declare -a directories=(
  projects/11/Seven
  projects/11/ConvertToBin
  projects/11/Square
  projects/11/Average
  projects/11/Pong
  projects/11/ComplexArrays
)

# Generate
for i in ${directories[@]}; do
  $(cd programs/compiler; swift run Compiler ../../$i)
done
