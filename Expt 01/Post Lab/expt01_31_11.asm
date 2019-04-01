;Experiment 01    Part 2   Final code, Microprocessors Lab
;Designed by Vasant, updated on 8th August 2018
;This assmebly works for all sorts of hex input  00XX or XX00 or XXXX or 0000
ORG 00H
LJMP MAIN
ZEROCHECK1:
	MOV A, 61H
	JZ ZEROCHECK0
	JNZ ZEROCHECK3
ZEROCHECK0: ;D1 is zero
	MOV A, 60H
	JZ RETURN	   ;D0 is also zero
	JNZ LOOPz  ;D0 is not  zero  
ZEROCHECK2:;if the prog proceeds till here, then, D1 is non zero and D0 is zero
	SJMP LOOP1s	  ; 
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

RETURN: RET
MAIN:
	MOV SP, #0CFH
	MOV R0, #80H
	MOV @R0, #14H
	mov b,@r0
	MOV 60H, B
	inc r0
	;MOV R1, #81H
	MOV @R0, #02H
	mov a, @r0					 ; we have b instead of R0 and R1 as R1.
	mov r1, A
	MOV 61H, R1	
	MOV R0, #00H
	MOV R1, #00H
	ACALL ZEROCHECK1
IDLE:
	SJMP IDLE
END