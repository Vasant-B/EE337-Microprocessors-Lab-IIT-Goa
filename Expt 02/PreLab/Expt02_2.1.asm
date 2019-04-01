; Vasant 12th Aug 2018  Experiment 02  Adding 16bit numbers in the 2s complement form
;assuming aXXX XXXX	XXXX XXXX a in the number represents sign and the rest, the magnitude.


ORG 0000H
LJMP MAIN


MAIN:
	MOV 41H, #0FEH
	MOV 40H, #0BEH
	MOV 51H, #0FFH
	MOV 50H, #0FFH
	SJMP ADDER16bit2scomplement

ADDER16bit2scomplement:
	CLR C
	MOV A, 40H
	ADD A, 50H
	MOV 60H, A
	MOV A, 41H
	ADDC A, 51H
	MOV 61H, A


	JNB OV, CASE_NOOV
	JB OV, CASE_OV
CASE_NOOV:	   ;Case no overflow
	JC CASECARRY_NOOV
	JNC CASENOCARRY_NOOV

	CASECARRY_NOOV: MOV 62H, #01H
					SJMP IDLE
	CASENOCARRY_NOOV: MOV 62H, #00H
					SJMP IDLE

CASE_OV:	   ;Case overflow
	JC CASECARRY_OV
	JNC CASENOCARRY_OV

	CASECARRY_OV: MOV 62H, #01H
					SJMP IDLE
	CASENOCARRY_OV: MOV 62H, #00H
					SJMP IDLE

IDLE:
	SJMP IDLE
END