#!/bin/bash

TESTS="./projects/01/*.tst"
for f in $TESTS
do
    ./tools/HardwareSimulator.sh $f
done