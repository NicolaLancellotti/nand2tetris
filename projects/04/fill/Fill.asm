// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

    // -1 -> if a key is pressed
    //  0 -> otherwise
    @isPressed
    M = 0

(LOOP)
    @KBD
    D = M
    @UNPRESSED
    D; JEQ
    
    // PRESSED
    @isPressed
    D = M
    @LOOP 
    D; JNE

    @isPressed
    M = -1
    @PRINT 
    0; JMP

(UNPRESSED)
    @isPressed
    D = M
    @LOOP 
    D; JEQ

    @isPressed
    M = 0

(PRINT)
    // end = SCREEN + 256 * 512 / 16 = SCREEN + 8192 
    @SCREEN
    D = A
    @end
    M = D
    @8192
    D = A
    @end
    M = M + D
    
    // i = SCREEN
    @SCREEN
    D = A

    @i
    M = D

(PRINT_LOOP)
    // if i == end goto LOOP
    @i
    D = M
    @end
    D = M - D
    @LOOP
    D; JEQ

    // *i = isPressed
    @isPressed
    D = M
    @i
    A = M
    M = D

    // i += 1
    @i
    M = M + 1

    @PRINT_LOOP 
    0; JMP
    