# x86assembly-io-procs

This project uses lower-level programming concepts such as memory addressing/management and pointers to convert user-inputted numbers (represented in ASCII) to their literal numerical value and then reconvert these literal numerical values back to ASCII so that they can be outputted to the screen. The program also calculates the sum and average of the numbers inputted by the user, and displays their value to the output. 

This program intentionally incorporates the use of macros to handle getting user input and displaying output.

Procedures are used for handling converting the string of ASCII code to a decimal representation, storing these decimal values in an array, and then another procedure handles converting the values in the array back to ASCII code so they can be outputted to the screen.

This code is written in x86 Assembly in MASM syntax meant for the Microsoft assembler.
