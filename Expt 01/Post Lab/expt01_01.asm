;Experiment 01    Part 1   Final code, Microprocessors Lab
;Designed by Vasant, updated on 8th August 2018
;This assmebly works for all sorts of hex input  00XX or XX00 or XXXX or 0000
ORG 00H
MAIN:
	MOV 60H, #05H
	MOV 61H, #02H
	MOV R0, 60H
	MOV R1, 61H
ZEROCHECK1:
	MOV A, R1
	JZ ZEROCHECK0
;ZEROCHECK3:
	MOV A, R0 ;R1 is non zero, so, see R0
	JZ ZEROCHECK2
	
LOOP1s:
	DJNZ R0, LOOP1s
	DJNZ R1, LOOP1s
LOOPz:
	DJNZ R0, LOOPz
IDLE:
	SJMP IDLE
ZEROCHECK0: ;R1 is zero
	MOV A, R0
	JZ IDLE	   ;R0 is also zero
	JNZ LOOPz  ;R0 is not  zero  
ZEROCHECK2:;if the prog proceeds till here, then, R1 is non zero and R0 is zero
	DEC R1
	SJMP LOOP1s	
END