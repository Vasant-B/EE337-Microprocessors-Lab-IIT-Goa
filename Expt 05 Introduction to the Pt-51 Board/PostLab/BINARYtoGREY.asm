;Vasant	2018-09-19
;Expt 5 - BIN2GREY
ORG 00H
LJMP MAIN
;--------------------------------------------------
MAIN:
	;configuring lower nibble of p1	as input and higher nibble of p1 as output
	MOV A, #0FH
	MOV P1, A

	HERE:
		MOV A, P1
		;MOV A, #00001001B  This can be uncommented to test the program	during simulation
		ANL A, #0FH
		MOV B, A
		RR A
		XRL A, B
		ANL A, #0FH

		;MOV A.3, B.3 rest of the bits of the accumulator are to be preserved
		MOV R0, A
		MOV R1, B
		MOV A, B
		ANL A, #00001000B
		JZ MSB_ZERO
		JNZ MSB_ONE
		MSB_ZERO:
			MOV A, R0
			ANL A, #00000111B
			SJMP MSB_CONTINUE
		MSB_ONE:
			MOV A, R0
			ANL A, #00000111B
			ORL A, #00001000B
			SJMP MSB_CONTINUE		
		MSB_CONTINUE:

		SWAP A
		ORL A, #0FH ;to configure lower nibble as input

		MOV P1, A
		SJMP HERE
END
