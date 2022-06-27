#!/bin/bash

declare -a directories=(
  projects/10/ExpressionLessSquare
  projects/10/Square
  projects/10/ArrayTest
)

# Generate
for i in ${directories[@]}; do
  $(cd programs/compiler; swift run Tokenizer ../../$i)
  $(cd programs/compiler; swift run ASTDumper ../../$i)
done

# Tokenizer
./tools/TextComparer.sh projects/10/ExpressionLessSquare/MainT.xml projects/10/ExpressionLessSquare/MainT2.xml
./tools/TextComparer.sh projects/10/ExpressionLessSquare/SquareT.xml projects/10/ExpressionLessSquare/SquareT2.xml
./tools/TextComparer.sh projects/10/ExpressionLessSquare/SquareGameT.xml projects/10/ExpressionLessSquare/SquareGameT2.xml
./tools/TextComparer.sh projects/10/Square/MainT.xml projects/10/Square/MainT2.xml
./tools/TextComparer.sh projects/10/Square/SquareT.xml projects/10/Square/SquareT2.xml
./tools/TextComparer.sh projects/10/Square/SquareGameT.xml projects/10/Square/SquareGameT2.xml
./tools/TextComparer.sh projects/10/ArrayTest/MainT.xml projects/10/ArrayTest/MainT2.xml

# ASTDumper
./tools/TextComparer.sh projects/10/ExpressionLessSquare/Main.xml projects/10/ExpressionLessSquare/Main2.xml
./tools/TextComparer.sh projects/10/ExpressionLessSquare/Square.xml projects/10/ExpressionLessSquare/Square2.xml
./tools/TextComparer.sh projects/10/ExpressionLessSquare/SquareGame.xml projects/10/ExpressionLessSquare/SquareGame2.xml
./tools/TextComparer.sh projects/10/Square/Main.xml projects/10/Square/Main2.xml
./tools/TextComparer.sh projects/10/Square/Square.xml projects/10/Square/Square2.xml
./tools/TextComparer.sh projects/10/Square/SquareGame.xml projects/10/Square/SquareGame2.xml
./tools/TextComparer.sh projects/10/ArrayTest/Main.xml projects/10/ArrayTest/Main2.xml       