TITLE Designing low-level I/O procedures     (Proj6_salaris.asm)

; Author: Sirus Salari
; Last Modified: 12/03/2023
; OSU email address: salaris@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 12/10/2023
; Description: This project uses lower-level programming concepts to convert user-inputted numbers (represented in ASCII) to
;	their literal numerical value. The program then reconverts these literal numerical values back to ASCII so that they can be outputted
;	to the screen.
;	The program also calculates the sum and average of the numbers inputted by the user, and displays their value to the output.
;	This program intentionally incorporates the use of macros, procedures, and loops.

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Prompts user to enter a numerical value, then reads their input, and stores the input into an output parameter.
;
; Preconditions: do not use eax, ecx, edx, and edi as arguments
;
; Receives:
; prompt = an input character array that is meant to prompt user to enter value
; memLocation = a location that you want to store the user input (location should be a character array)
; byteCount = defined maximum number of bytes/characters/digits that the user can enter
; bytesRead = amount of bytes/characters/digits entered by the user
;
; returns: bytesRead = the amount of bytes entered by the user
; ---------------------------------------------------------------------------------


mGetString macro prompt, memLocation, byteCount, bytesRead
	push	edx
	push	eax
	push	ecx
	push	edi

	mov		edi, bytesRead

	mov		edx, prompt
	call	WriteString

	; Preconditions of ReadString: ecx contains max number of characters that can be inputted and edx points to the array to store the input
	; Postconditions of ReadString: eax contains the number of characters entered
	mov		ecx, byteCount
	mov		edx, memLocation
	call	ReadString
	mov		[edi], eax
	mov		bytesRead, edi


	pop		edi
	pop		ecx
	pop		eax
	pop		edx
endm

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Displays a character array to the output.
;
; Preconditions: do not use edx.
;
; Receives:
; mem_location = an input character array that you want outputted.

;
; returns: none.
; ---------------------------------------------------------------------------------

mDisplayString macro mem_location
	push edx

	mov		edx, mem_location
	call	WriteString

	pop edx
endm	

.data

numberPrompt	 byte "Please enter a signed number: ", 0
numberString	 byte 12 dup(?)
numberByteCount	 dword 12
numberBytesRead  dword 10 dup(?)
numberByteRead   dword ?
errorMessage	 byte "ERROR: You did not enter a signed number or your number was too big", 13, 10, 0

numberValue		 sdword ?
numberValues	 sdword 10 dup(?)
numberIsNegative dword 0

reversedString	 byte 12 dup(?)
forwardString	 byte 12 dup(?)
resetString		 byte 12 dup(?)

displayMessage	 byte 13, 10, "You entered the following numbers:", 13, 10, 0
spacing			 byte ", ", 0

sumMessage		 byte "The sum of these numbers is: ", 0
averageMessage	 byte "The truncated average is: ", 0
goodbyeMessage	 byte 13, 10, "Thanks for playing!", 13, 10, 0


.code
main PROC
	
	mov		ecx, 10
	mov		edi, offset numberValues
	mov		esi, offset numberBytesRead

	; Loop to repeatedly get 10 values from user
	_getNumbers:
		
		push numberIsNegative
		push offset numberValue
		push offset errorMessage
		push offset numberByteRead
		push numberByteCount
		push offset numberString
		push offset numberPrompt
		call ReadVal

		; Store returned numberValue and numberByteRead in their respective arrays

		mov	eax, numberValue
		mov	ebx, numberByteRead

		; Point to next element in each array

		mov	[edi], eax
		add edi, 4

		mov	[esi], ebx
		add esi, 4

		loop _getNumbers

	; Display message prior to displaying all of the values entered by the user.
	mdisplayString offset displayMessage

	mov	ecx, 10
	mov esi, offset numberValues
	mov	edi, offset numberBytesRead

	; Loop to repeatedly display each of the 10 values entered by the user.
	_displayNumbers:
		
		; Load numberValue and numberByteRead with the current element from their respective array.
		mov	eax, [esi]
		mov	numberValue, eax

		mov	ebx, [edi]
		mov	numberByteRead, ebx

		push offset resetString
		push offset forwardString
		push numberByteRead
		push offset reversedString
		push numberValue
		call WriteVal

		; Point to next element for each array
		
		add	esi, 4
		add edi, 4

		; Put a comma and a space after each number (except the last number)
		cmp	ecx, 1
		ja	_putSpacing

		loop _displayNumbers

	jmp	_final

	_putSpacing:

		mdisplayString offset spacing
		loop _displayNumbers

	_final:
		call CrLf

		; Display message indicating a sum value
		mdisplayString offset sumMessage

		mov		esi, offset numberValues
		mov		eax, 0
		mov		ecx, 10

		; Iterate through numberValues to calculate the sum of the numbers
		_sumNumberLoop:

			add		eax, [esi]
			
			add		esi, 4

			loop _sumNumberLoop

		call	WriteDec
		call	CrLf

		; Display message indicating an average value
		mdisplayString offset averageMessage

		mov		edx, 0
		mov		ebx, 10
		idiv	ebx
		call	WriteDec
		call	CrLf

		; Display outro message
		mdisplayString offset goodbyeMessage

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Takes in an array of ASCII code and stores it in numberValue variable using the stack.
; This procedure invokes the mGetString macro to prompt the user to enter a value and
; then return the string to the procedure. This procedure also invokes the mDisplayString
; if a user enters a number that is too large or enters invalid characters.
;
; Preconditions: none.
;
; Postconditions: none.
;
; Receives:
; [ebp + 32] = numberIsNegative (a variable that's used as a Boolean within the proc. to know
;				if the number entered by the user is negative)
; [ebp + 28] = address of numberValue (a variable that will hold the decimal value of the number
;				entered by the user)
; [ebp + 24] = address of errorMessage (a message that's displayed when user enters
;				number that is too large or contains invalid characters)
; [ebp + 20] = address of numberByteRead (a variable that will hold the number of characters
;				entered by user)
; [ebp+16] = numberByteCount (defined maximum number of characters that user can enter)
; [ebp+12] = address of numberString (address where user inputted string will be stored)
; [ebp+8] = address of numberPrompt (prompt for user to enter number)
; arrayMsg, arrayError are global variables
;
; returns: numberValue and numberByteRead
; ---------------------------------------------------------------------------------

ReadVal proc
	push	ebp
	mov		ebp, esp
	push	ebx
	push	ecx
	push	esi
	push	eax
	push	edx
	push	edi
	
	_getString:
		mGetString	 [ebp + 8], [ebp + 12], [ebp + 16], [ebp + 20]

		mov		esi, [ebp + 12]

		mov		edi, [ebp + 20]
		mov		eax, [edi]

		mov		edi, [ebp + 28]

		mov		ebx, 0
		mov		ecx, eax

	_convertString:
		
		; Algorithm to convert ASCII code to decimal representation
		mov		eax, 10
		mul		ebx
		jc		_invalid
		mov		ebx, eax
		mov		eax, 0 ; reset register
		lodsb

		; If ASCII is below 48, check to see if it's a "plus" or "minus" sign
		cmp		al, 48
		jb		_checkForSign

		; If ASCII is above 57, then the character is invalid
		cmp		al, 57
		ja		_invalid

		sub		al, 48

		; Store decimal value in ebx
		add		ebx, eax

		loop	_convertString
	
	; store decimal value in numberValue
	mov		[edi], ebx
	
	; Boolean to check if number is negative, then make value negative
	cmp		dword ptr [ebp + 32], 1
	je		_makeNegative

	jmp		_finish

	_checkForSign:

		cmp		al, 43
		je		_plusSign

		cmp		al, 45
		je		_minusSign

	_plusSign:

		loop _convertString

	_minusSign:
		
		; If user entered "minus" sign, then set numberIsNegative to 1
		mov		dword ptr [ebp + 32], 1
		loop	_convertString

	_invalid:
		
		; Display error message if user enters invalid input or too large of a number
		mDisplayString [ebp + 24]
		jmp	_getString

	_makeNegative:
		
		imul	eax, [edi], -1
		mov		[edi], eax

	_finish:

		pop		edi
		pop		edx
		pop		eax
		pop		esi
		pop		ecx
		pop		ebx
		pop		ebp
		ret		28
ReadVal endp

; ---------------------------------------------------------------------------------
; Name: writeVal
;
; Takes in a decimal value and converts the value to ASCII code. This procedure
; invokes the mDisplayString macro to display the character representation of the
; decimal values.
;
; Preconditions: numberValues and numberBytesRead arrays are filled with 10 elements
; each. numberValue and numberByteRead variables contain the value of the current index
; of their respective arrays.
;
; Postconditions: none.
;
; Receives:
; [ebp+24] = address of resetString (an empty character array that will be used to reset
;			the forwardString variable to being empty before the next procedure call).
; [ebp+20] = address of forwardString (a character array that will store the sorted ASCII
;			code).
; [ebp+16] = numberByteRead (the amount of characters entered by the user when they entered
;			the input.
; [ebp+12] = address of reversedString (a character array that will contain the ASCII
;			code for the decimal value, but in reverse order)
; [ebp+8] = numberValue (a decimal value)
; arrayMsg, arrayError are global variables
;
; returns: none.
; ---------------------------------------------------------------------------------

WriteVal proc
	push	ebp
	mov		ebp, esp
	push	ecx
	push	eax
	push	edx
	push	ebx
	push	edi
	push	esi

	mov		esi, [ebp + 8]

	mov		edi, [ebp + 12]

	mov		ecx, 1
	mov		ebx, 10

	; check if it is negative
	cmp		esi, 0
	jge		_convertToASCII
	
	; If code reaches this point, then number is negative.
	mov		ecx, [ebp + 16]
	add		edi, ecx
	dec		edi

	; Put "minus" sign at end of reversedString
	mov		byte ptr [edi], 45

	inc		edi
	sub		edi, ecx

	mov		esi, [ebp + 8]
	mov		ecx, 1

	; Convert decimal value to positive so that decimal can be converted to ASCII
	imul	eax, esi, -1
	mov		esi, eax

	_convertToASCII:
		
		; Algorithm to convert decimal value to ASCII

		; Extract the digit
		mov		eax, esi
		mov		edx, 0
		div		ecx


		cmp		eax, 0
		je		_final

		mov		edx, 0
		div		ebx

		; Convert digit to ASCII and store in reversedString
		mov		eax, edx
		add		eax, 48
		stosb

		mov		eax, ecx
		mul		ebx
		mov		ecx, eax
		jmp		_convertToASCII

	_final:
		mov	ecx, [ebp + 16]

		mov	esi, [ebp + 12]
		add	esi, ecx
		dec esi

		mov edi, [ebp + 20]

		; Loop to iterate through reversedString and store each byte into forwardString
		_revLoop:

			std
			lodsb
			cld
			stosb

			loop _revLoop

		; Display the ASCII code as a character string to the output
		mDisplayString [ebp + 20]

		mov	esi, [ebp + 24]
		mov	edi, [ebp + 20]
		mov	ecx, 12

		; Loop to reset the forwardString back to empty before the next procedure call.
		_clearString:

			lodsb
			mov	[edi], al

			inc edi
			loop _clearString

	pop		esi
	pop		edi
	pop		ebx
	pop		edx
	pop		eax
	pop		ecx
	pop		ebp
	ret		20
WriteVal endp
END main
