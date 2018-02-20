TITLE Program #4     (Program4.asm)

;Author: Tida Sooreechine
;Email: sooreect@oregonstate.edu
;Course: CS271-400
;Project ID: Program #4               
;Assignment Due Date: July 31, 2016
;Description: Program generates an array of randomly generated number, before and after sorting,
;	from user input. Program also computes the array's median value.

INCLUDE Irvine32.inc


MIN = 10
MAX = 200
LO = 100
HI = 999


.data

userInput		DWORD	?
list			DWORD	MAX DUP(?)
elementCount	DWORD	0
title1			BYTE	"Sorting Random Integers", 0
title2			BYTE	"Programmed by Tida Sooreechine", 0
description1	BYTE	"This program generates random numbers in the range [100 .. 999], displays", 0
description2	BYTE	"the original list, sorts the list, and calculates the median value.", 0
description3	BYTE	"Finally, it displays the list sorted in descending order.", 0
prompt			BYTE	"How many numbers should be generated? [10 .. 200]: ", 0
error			BYTE	"Invalid input.", 0
result1			BYTE	"The unsorted list of random numbers: ", 0
result2			BYTE	"The sorted list of random numbers: ", 0
resultMedian	BYTE	"The median is ", 0
space			BYTE	"     ", 0
period			BYTE	".", 0


.code

main PROC
	;print program introduction
	push	OFFSET title1			;ebp+24
	push	OFFSET title2			;ebp+20
	push	OFFSET description1		;ebp+16
	push	OFFSET description2		;ebp+12
	push	OFFSET description3		;ebp+8
	call	introduction

	;get and validate user input
	push	OFFSET userInput		;ebp+16/pass by reference
	push	OFFSET prompt			;ebp+12
	push	OFFSET error			;ebp+8
	call	getData

	;fill array of userInput number of elements with random integers
	call	Randomize				;initialize starting seed value for RandomRange
	push	OFFSET list				;ebp+12/pass by reference
	push	userInput				;ebp+8/pass by value
	call	fillArray
	
	;display the unsorted array of random integers
	push	elementCount			;ebp+24
	push	OFFSET space			;ebp+20
	push	OFFSET result1			;ebp+16/pass by reference
	push	OFFSET list				;ebp+12/pass by reference
	push	userInput				;ebp+8/pass by value
	call	printList

	;sort the array elements in descending order (largest to smallest)
	push	OFFSET list				;ebp+12/pass by reference
	push	userInput				;ebp+8/pass by value
	call	sortList

	;calculate the median value of array
	push	OFFSET period			;ebp+20
	push	OFFSET resultMedian		;ebp+16
	push	OFFSET list				;ebp+12/pass by reference
	push	userInput				;ebp+8/pass by value
	call	medianCalc

	;display the sorted array of random integers
	mov		elementCount, 0			;reset count
	push	elementCount			;ebp+24
	push	OFFSET space			;ebp+20
	push	OFFSET result2			;ebp+16/pass by reference
	push	OFFSET list				;ebp+12/pass by reference
	push	userInput				;ebp+8/pass by value
	call	printList

	exit	; exit to operating system
main ENDP


;----------------------------------------------------------------------------------------
;Procedure: Prints program title and description to the user
;Receives: The memory addresses of global variables title1-title2 & 
;	description1-description3 via system stack
;Returns: None
;Preconditions: None  
;Registers Changed: EDX & EBP
;----------------------------------------------------------------------------------------
introduction PROC
	push	ebp
	mov		ebp, esp

	mov		edx, [ebp+24]			;print title1
	call	WriteString
	call	crlf
	mov		edx, [ebp+20]			;print title2
	call	WriteString
	call	crlf
	call	crlf
	
	mov		edx, [ebp+16]			;print description1
	call	WriteString
	call	crlf
	mov		edx, [ebp+12]			;print description2
	call	WriteString
	call	crlf
	mov		edx, [ebp+8]			;print description3
	call	WriteString
	call	crlf
	call	crlf
	
	pop		ebp						
	ret		20					
introduction ENDP

;----------------------------------------------------------------------------------------
;Procedure: Gets, validates, and stores integer input from user
;Receives: The memory addresses of global variables userInput, prompt, and error
;	via system stack
;Returns: User input value as global variable, userInput
;Preconditions: None
;Registers Changed: EAX, EBX, EDX & EBP
;----------------------------------------------------------------------------------------
getData PROC
	push	ebp
	mov		ebp, esp

validateInput:
	mov		edx, [ebp+12]			;print prompt
	call	WriteString
	call	ReadInt					;user input stored in eax	

	;validate integer input by comparing it to min and max values specified
	cmp		eax, MIN		
	jl		printError
	cmp		eax, MAX
	jg		printError
	call	crlf
	jmp		endValidate

	;print error messages and reenter validation loop
printError:
	mov		edx, [ebp+8]
	call	WriteString
	call	crlf
	call	crlf
	jmp		validateInput

	;user input is valid
	;store in global variable and return to main
endValidate:	
	mov		ebx, [ebp+16]
	mov		[ebx], eax			
		
	pop		ebp
	ret		12
getData ENDP

;----------------------------------------------------------------------------------------
;Procedure: Generates an array of userInput number of elements filled with random 
;	integers within specified range
;Receives: Starting address of array and userInput value via system stack
;Returns: An array filled with random integers 
;Preconditions: userInput is valid and within range
;Registers Changed: EAX, ECX, EBP & EDI
;----------------------------------------------------------------------------------------
fillArray PROC
	push	ebp
	mov		ebp, esp

	;set up array and loop counter
	mov		edi, [ebp+12]			;@list in edi
	mov		ecx, [ebp+8]			;number of elements in ecx

	;fill each array element with random integer
fillRepeat:		;source: OSU CS271 Lectures#19-20
	;get random integer within range
	mov		eax, HI					;999
	sub		eax, LO					;999-100=899
	inc		eax						;900
	call	RandomRange				;eax in [0..899]
	add		eax, LO					;eax in [100..999]
	;store value in array element
	mov		[edi], eax				
	add		edi, 4					
	loop	fillRepeat

	pop		ebp
	ret		8
fillArray ENDP

;----------------------------------------------------------------------------------------
;Procedure: Reverse bubblesort algorithm/sorts array elements in descending order
;Receives: Memory address of array's first element and userInput value
;Returns: A sorted array, ordered from largest to smallest number
;Preconditions: Array must have elements
;Registers Changed: EAX, ECX, ESI & EBP
;----------------------------------------------------------------------------------------
sortList PROC
	push	ebp
	mov		ebp, esp

	;set up loop counter
	mov		ecx, [ebp+8]			;number of elements in ecx
	dec		ecx						;decrement count by 1

	;begin sorting
outerLoop:	
	push	ecx						;save outer loop count
	mov		esi, [ebp+12]			;point to the first element
innerLoop:	
	mov		eax, [esi]				;get value of current element
	cmp		[esi+4], eax			;compare values between current and subsequent elements
	jl		noSwap					;if subsequent value is less, don't swap
	xchg	eax, [esi+4]			;exchange values
	mov		[esi], eax				
noSwap:
	add		esi, 4					;move to the next elements
	loop	innerLoop				;repeat inner loop
	pop		ecx						;retrieve outer loop count
	loop	outerLoop				;else repeat outer loop		

	pop		ebp
	ret		8
sortList ENDP

;----------------------------------------------------------------------------------------
;Procedure: Generates the median value of an array.
;Receives: Memory addresses of array's first element and result's title and value of 
;	element count in array.
;Returns: A single integer that is either the median value or the average of 2 middle 
;	values
;Preconditions: Array has sorted elements
;Registers Changed: EAX, EBX, EDX & ESI
;----------------------------------------------------------------------------------------
medianCalc PROC
	push	ebp
	mov		ebp, esp

	mov		edx, [ebp+16]			;print result's title
	call	WriteString	
	mov		esi, [ebp+12]			;@list
	mov		edx, 0
	mov		eax, [ebp+8]			;get number of array elements
	mov		ebx, 2
	div		ebx						;determine if even or odd count
	cmp		edx, 0					;check remainder
	jne		oddCount				
	jmp		evenCount				
oddCount:
	mov		ebx, 4					
	mul		ebx						;size of offset in bytes in eax
	add		esi, eax				;offset to the array element containing median value
	mov		eax, [esi]
	call	WriteDec				;print median value
	mov		edx, [ebp+20]			
	call	WriteString				;add period
	call	crlf
	call	crlf
	jmp		done					
evenCount:
	mov		ebx, 4					
	mul		ebx						;size of offset in bytes in eax
	add		esi, eax				;offset to the bigger of the two elements in the middle
	mov		eax, [esi]				;eax contains bigger value of the two middle elements
	add		eax, [esi-4]			;add the value of the smaller of the two middle elements
	mov		ebx, 2
	mov		edx, 0					;clear edx
	div		ebx						;get avg of middle values/quotient in eax, remainder in edx
	cmp		edx, 0					;if remainder exists, its value is 0.5, so round up
	je		noRounding				
	inc		eax						;rounding up
noRounding:
	call	WriteDec				;print median value
	mov		edx, [ebp+20]			
	call	WriteString				;add period
	call	crlf
	call	crlf


done:
	pop		ebp
	ret		16
medianCalc ENDP

;----------------------------------------------------------------------------------------
;Procedure: Prints the elements in an array, 10 items per line.
;Receives: Memory addresses of array, array's title, and blank space, along with values
;	of elementCount and userInput
;Returns: Individual elements of array passed
;Preconditions: Array has elements and userInput is valid
;Registers Changed: EBX, ECX, EDX, ESI & EBP
;Source: Assembly Language for x86 Processors (7th Edition), p.375
;----------------------------------------------------------------------------------------
printList PROC
	push	ebp
	mov		ebp, esp

	;print list's title
	mov		edx, [ebp+16]			
	call	WriteString
	call	crlf

	;set up array and loop counter
	mov		esi, [ebp+12]			;@list in esi
	mov		ecx, [ebp+8]			;number of elements in ecx
	mov		ebx, [ebp+24]			;number of element already printed per line in ebx
	
	;print each element
printRepeat:	;source: OSU CS271 Lecture#20
	mov		eax, [esi]				;copy value of current element into eax
	call	WriteDec				;print value
	add		esi, 4					;go to the next element
	inc		ebx						;current count of elements printed on the line
	cmp		ebx, 10					;10 is the max outputs allowed per line
	jge		nextLine				;proceed to the next line if max is reached
	mov		edx, [ebp+20]			;print space between elements
	call	WriteString				
	jmp		sameLine				;continue on the same line, otherwise
nextLine:	
	call	crlf
	mov		ebx, 0					
sameLine:
	loop	printRepeat
	call	crlf
	call	crlf

	pop		ebp
	ret		20
printList ENDP

END main