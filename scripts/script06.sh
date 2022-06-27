#!/bin/bash

declare -a files=(
  projects/06/add/Add.asm
  projects/06/max/Max.asm
  projects/06/pong/Pong.asm
  projects/06/rect/Rect.asm)

for i in ${files[@]}; do
  $(cd programs/assembler; cargo run ../../$i)
done
