;Experiment 01    Part 2   Final code, Microprocessors Lab
;Designed by Vasant, updated on 8th August 2018
;This assmebly works for all sorts of hex input  00XX or XX00 or XXXX or 0000
ORG 00H
SJMP MAIN

ZEROCHECK1:
	MOV A, 61H
	JZ ZEROCHECK0
ZEROCHECK3:
	MOV A, 60H ;D1 is non zero, so, see D0
	JZ ZEROCHECK2
	
LOOP1s:
	INC R0
	MOV A, R0
	CJNE R0, #0ffH, LOOP1s
	INC R1
	MOV A, R1
	CJNE A, 61H, LOOP1s
LOOPz:
	INC R0
	MOV A, R0
	CJNE A, 60H, LOOPz
	SJMP RETURN
ZEROCHECK0: ;D1 is zero
	MOV A, 60H
	JZ RETURN	   ;D0 is also zero
	JNZ LOOPz  ;D0 is not  zero  
ZEROCHECK2:;if the prog proceeds till here, then, D1 is non zero and D0 is zero
	SJMP LOOP1s	  ; 
RETURN: RET
MAIN:
	MOV 60H, #05H ; Call this value D0
	MOV 61H, #01H ; Call this value D1
	MOV R0, #00H
	MOV R1, #00H
IDLE:
	SJMP IDLE
 
END