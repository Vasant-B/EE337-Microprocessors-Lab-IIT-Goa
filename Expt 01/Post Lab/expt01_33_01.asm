;Experiment 01    Part 3    Microprocessors Lab
;Designed by Vasant, updated on 9th August 2018

ORG 00H
LJMP MAIN



ADDERLOOP:
	MOV A, 49H
	;MOV A, @R0
	INC R1
	INC R0
	
	ADD A, R1
	MOV @R0, A
	MOV 49H, A
	MOV A, R1
	CJNE A, 50H, ADDERLOOP

RETURN: RET
MAIN:
;	MOV SP, #0CFH
	MOV 50H, #06H
	MOV R1, #00H ;integer needed to add
	MOV R0, #50H ;pointer 
	MOV A, #01H
	ACALL ADDERLOOP
IDLE: SJMP IDLE
END