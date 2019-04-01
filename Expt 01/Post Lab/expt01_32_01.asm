;Experiment 01    Part 3    Microprocessors Lab
;Designed by Vasant, updated on 9th August 2018

ORG 00H
LJMP MAIN

F2_ADDER:
	MOV A, 50H
	ADD A, 60H
	MOV 70H, A
	CLR 71H
	JNC RETURN
	ORL 71H, #01H

RETURN: RET

MAIN:
	MOV SP, #0CFH
	MOV 50H, #10H
	MOV 60H, #20H

	ACALL F2_ADDER
IDLE:
	SJMP IDLE
END