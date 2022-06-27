@256
D = A
@SP
M = D
@$ret.0
D = A
@SP
AM = M + 1
A = A - 1
M = D
@LCL
D = M
@SP
AM = M + 1
A = A - 1
M = D
@ARG
D = M
@SP
AM = M + 1
A = A - 1
M = D
@THIS
D = M
@SP
AM = M + 1
A = A - 1
M = D
@THAT
D = M
@SP
AM = M + 1
A = A - 1
M = D
@SP
D = M
@5
D = D - A
@0
D = D - A
@ARG
M = D
@SP
D = M
@LCL
M = D
@Sys.init
0; JMP
($ret.0)
(Main.fibonacci)
@ARG
D = M
@0
A = D + A
D = M
@SP
AM = M + 1
A = A - 1
M = D
@2
D = A
@SP
AM = M + 1
A = A - 1
M = D
@SP
AM = M - 1
D = M
@R13
M = D
@SP
AM = M - 1
D = M
@R13
D = D - M
@Main.fibonacci$true.0
D; JLT
D = 0
@Main.fibonacci$end.0
0; JMP
(Main.fibonacci$true.0)
D = -1
(Main.fibonacci$end.0)
@SP
AM = M + 1
A = A - 1
M = D
@SP
AM = M - 1
D = M
@Main.fibonacci$IF_TRUE
D; JNE
@Main.fibonacci$IF_FALSE
0; JMP
(Main.fibonacci$IF_TRUE)
@ARG
D = M
@0
A = D + A
D = M
@SP
AM = M + 1
A = A - 1
M = D
@LCL
D = M
@R13
M = D
@5
A = D - A
D = M
@R14
M = D
@SP
AM = M - 1
D = M
@ARG
A = M
M = D
D = A + 1
@SP
M = D
@R13
AM = M - 1
D = M
@THAT
M = D
@R13
AM = M - 1
D = M
@THIS
M = D
@R13
AM = M - 1
D = M
@ARG
M = D
@R13
AM = M - 1
D = M
@LCL
M = D
@R14
A = M
0; JMP
(Main.fibonacci$IF_FALSE)
@ARG
D = M
@0
A = D + A
D = M
@SP
AM = M + 1
A = A - 1
M = D
@2
D = A
@SP
AM = M + 1
A = A - 1
M = D
@SP
AM = M - 1
D = M
@R13
M = D
@SP
AM = M - 1
D = M
@R13
D = D - M
@SP
AM = M + 1
A = A - 1
M = D
@Main.fibonacci$ret.0
D = A
@SP
AM = M + 1
A = A - 1
M = D
@LCL
D = M
@SP
AM = M + 1
A = A - 1
M = D
@ARG
D = M
@SP
AM = M + 1
A = A - 1
M = D
@THIS
D = M
@SP
AM = M + 1
A = A - 1
M = D
@THAT
D = M
@SP
AM = M + 1
A = A - 1
M = D
@SP
D = M
@5
D = D - A
@1
D = D - A
@ARG
M = D
@SP
D = M
@LCL
M = D
@Main.fibonacci
0; JMP
(Main.fibonacci$ret.0)
@ARG
D = M
@0
A = D + A
D = M
@SP
AM = M + 1
A = A - 1
M = D
@1
D = A
@SP
AM = M + 1
A = A - 1
M = D
@SP
AM = M - 1
D = M
@R13
M = D
@SP
AM = M - 1
D = M
@R13
D = D - M
@SP
AM = M + 1
A = A - 1
M = D
@Main.fibonacci$ret.1
D = A
@SP
AM = M + 1
A = A - 1
M = D
@LCL
D = M
@SP
AM = M + 1
A = A - 1
M = D
@ARG
D = M
@SP
AM = M + 1
A = A - 1
M = D
@THIS
D = M
@SP
AM = M + 1
A = A - 1
M = D
@THAT
D = M
@SP
AM = M + 1
A = A - 1
M = D
@SP
D = M
@5
D = D - A
@1
D = D - A
@ARG
M = D
@SP
D = M
@LCL
M = D
@Main.fibonacci
0; JMP
(Main.fibonacci$ret.1)
@SP
AM = M - 1
D = M
@R13
M = D
@SP
AM = M - 1
D = M
@R13
D = D + M
@SP
AM = M + 1
A = A - 1
M = D
@LCL
D = M
@R13
M = D
@5
A = D - A
D = M
@R14
M = D
@SP
AM = M - 1
D = M
@ARG
A = M
M = D
D = A + 1
@SP
M = D
@R13
AM = M - 1
D = M
@THAT
M = D
@R13
AM = M - 1
D = M
@THIS
M = D
@R13
AM = M - 1
D = M
@ARG
M = D
@R13
AM = M - 1
D = M
@LCL
M = D
@R14
A = M
0; JMP
(Sys.init)
@4
D = A
@SP
AM = M + 1
A = A - 1
M = D
@Sys.init$ret.0
D = A
@SP
AM = M + 1
A = A - 1
M = D
@LCL
D = M
@SP
AM = M + 1
A = A - 1
M = D
@ARG
D = M
@SP
AM = M + 1
A = A - 1
M = D
@THIS
D = M
@SP
AM = M + 1
A = A - 1
M = D
@THAT
D = M
@SP
AM = M + 1
A = A - 1
M = D
@SP
D = M
@5
D = D - A
@1
D = D - A
@ARG
M = D
@SP
D = M
@LCL
M = D
@Main.fibonacci
0; JMP
(Sys.init$ret.0)
(Sys.init$WHILE)
@Sys.init$WHILE
0; JMP
