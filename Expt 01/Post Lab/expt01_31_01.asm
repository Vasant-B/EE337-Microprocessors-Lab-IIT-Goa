;Experiment 01    Part 3    Microprocessors Lab
;Designed by Vasant, updated on 9th August 2018
;This assmebly works for all sorts of hex input  00XX or XX00 or XXXX or 0000
ORG 00H
lJMP MAIN


ZEROCHECK1:	; Checking if R1 is zero
	MOV A, R1
	JZ ZEROCHECK0
	JNZ ZEROCHECK3

ZEROCHECK0: ;R1 is zero
	MOV A, b
	JZ IDLE	   ;R0 is also zero
	JNZ LOOPz  ;R0 is not  zero 

ZEROCHECK3:
	MOV A, b ;R1 is non zero, so, see R0
	JZ ZEROCHECK2
	JNZ LOOP1s
ZEROCHECK2:;if the prog proceeds till here, then, R1 is non zero and R0 is zero
	DEC R1
	SJMP LOOP1s
	
LOOP1s:
	DJNZ b, LOOP1s
	DJNZ R1, LOOP1s
LOOPz:
	DJNZ b, LOOPz

RETURN: RET

MAIN:
	MOV SP, #0CFH
	MOV R0, #80H
	MOV @R0, #14H
	mov b,@r0
	inc r0
	;MOV R1, #81H
	MOV @R0, #02H
	mov a, @r0					 ; we have b instead of R0 and R1 as R1.
	mov r1, A	

	ACALL ZEROCHECK1	
IDLE:
	SJMP IDLE
END
