;VASANT 22nd Aug 2018
;exp 3, lab work part 4 BIN2ASCII Using Compare and Jump

ORG 00H
LJMP MAIN

BIN2ASCII:
	USING 0
	PUSH PSW
	PUSH AR0
	PUSH AR1
	PUSH 50H
	BIN2ASCII_Loop0:
		MOV R0, 51H
		MOV R1, 52H
		BIN2ASCII_LOOP1:
		MOV A, @R0
		ANL A, #0F0H
		SWAP A
		CJNE A, #0AH, DO_MSB
		DO_MSB:
		JC DO_MSB_CARRY
		JNC DO_MSB_NOCARRY
		DO_MSB_CARRY:
			;number is 9 or less
			ADD A, #30H
			SJMP COMEBACK_MSB
		DO_MSB_NOCARRY:
			;number is A or greater
			ADD A, #37H
			SJMP COMEBACK_MSB
		COMEBACK_MSB:
		XCH A, @R1
		INC R1

		MOV A, @R0
		ANL A, #0FH
		CJNE A, #0AH, DO_LSB
		DO_LSB:
		JC DO_LSB_CARRY
		JNC DO_LSB_NOCARRY
		DO_LSB_CARRY:
			;number is 9 or less
			ADD A, #30H
			SJMP COMEBACK_LSB
		DO_LSB_NOCARRY:
			;number is A or greater
			ADD A, #37H
			SJMP COMEBACK_LSB
		COMEBACK_LSB:
		XCH A, @R1
		INC R1
		INC R0			
	DJNZ 50H, BIN2ASCII_Loop1
	POP 50H
	POP AR1
	POP AR0
	POP PSW
RET

MAIN:
   MOV 50H, #02		;Number N
   MOV 51H, #10H	;Read Pointer
   MOV 52H, #20H	;Write Pointer
   
   ;Pseudo Input
   MOV 10H, #04AH
   MOV 11H, #091H
   LCALL BIN2ASCII 
END
