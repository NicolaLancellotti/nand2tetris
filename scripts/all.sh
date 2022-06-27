#!/bin/bash

for f in  $(seq -f "%02g" 1 12)
do
    printf "\nScript $f\n"
    ./scripts/script${f}.sh
done