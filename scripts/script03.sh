#!/bin/bash

TESTS_A="./projects/03/a/*.tst"
TESTS_B="./projects/03/b/*.tst"

for f in $TESTS_A
do
    ./tools/HardwareSimulator.sh $f
done

for f in $TESTS_B
do
    ./tools/HardwareSimulator.sh $f
done