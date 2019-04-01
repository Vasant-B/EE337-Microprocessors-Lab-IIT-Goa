; Vasant 12th Aug 2018  Experiment 02  Subtracting 16bit numbers in the 2s complement form
;assuming aXXX XXXX	XXXX XXXX a in the number represents sign and the rest, the magnitude.

ORG 0000H
LJMP MAIN

MAIN:
	MOV 41H, #0FFH
	MOV 40H, #0FFH
	MOV 51H, #0FCH
	MOV 50H, #0DEH
	SJMP SUBTRACTOR16bit2scomplement

SUBTRACTOR16bit2scomplement:
	CLR C
	MOV A, 40H
	SUBB A, 50H
	MOV 60H, A
	MOV A, 41H
	SUBB A, 51H
	MOV 61H, A
	

	JNB OV, CASE_NOOV
	JB OV, CASE_OV

CASE_NOOV:	   ;Case no overflow
	JC CASEBORROW_NOOV
	JNC CASENOBORROW_NOOV

	CASEBORROW_NOOV: MOV 62H, #01H
					SJMP IDLE
	CASENOBORROW_NOOV: MOV 62H, #00H
					SJMP IDLE

CASE_OV:	   ;Case overflow
	JC CASEBORROW_OV
	JNC CASENOBORROW_OV

	CASEBORROW_OV: MOV 62H, #00H
					SJMP IDLE
	CASENOBORROW_OV: MOV 62H, #01H
					SJMP IDLE

IDLE:
	SJMP IDLE
END