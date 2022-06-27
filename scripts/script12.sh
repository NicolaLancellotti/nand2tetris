# #!/bin/bash

# -------------------------------------------------------------
# Array
cp projects/12/Array.jack projects/12/ArrayTest/Array.jack
./tools/JackCompiler.sh projects/12/ArrayTest
# -------------------------------------------------------------
# Keyboard
cp projects/12/Keyboard.jack projects/12/KeyboardTest/Keyboard.jack
cp projects/12/Math.jack projects/12/KeyboardTest/Math.jack
cp projects/12/Output.jack projects/12/KeyboardTest/Output.jack
./tools/JackCompiler.sh projects/12/KeyboardTest
# -------------------------------------------------------------
# Math
cp projects/12/Math.jack projects/12/MathTest/Math.jack
./tools/JackCompiler.sh projects/12/MathTest
# -------------------------------------------------------------
# Memory
cp projects/12/Memory.jack projects/12/MemoryTest/Memory.jack
./tools/JackCompiler.sh projects/12/MemoryTest

cp projects/12/Memory.jack projects/12/MemoryTest/MemoryDiag/Memory.jack
./tools/JackCompiler.sh projects/12/MemoryTest/
# -------------------------------------------------------------
# Output
cp projects/12/Output.jack projects/12/OutputTest/Output.jack
cp projects/12/Math.jack projects/12/OutputTest/Math.jack
./tools/JackCompiler.sh projects/12/OutputTest
# -------------------------------------------------------------
# Screen
cp projects/12/Screen.jack projects/12/ScreenTest/Screen.jack
./tools/JackCompiler.sh projects/12/ScreenTest
# -------------------------------------------------------------
# String
cp projects/12/String.jack projects/12/StringTest/String.jack
./tools/JackCompiler.sh projects/12/StringTest
# -------------------------------------------------------------
# Sys
cp projects/12/Sys.jack projects/12/SysTest/Sys.jack
./tools/JackCompiler.sh projects/12/SysTest
