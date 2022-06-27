#!/bin/bash

TESTS="./projects/02/*.tst"
for f in $TESTS
do
    ./tools/HardwareSimulator.sh $f
done
