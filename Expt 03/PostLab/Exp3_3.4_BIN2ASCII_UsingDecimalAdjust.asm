;VASANT 22nd Aug 2018
;exp 3, lab work part 4 BIN2ASCII using Decimal Adjust

ORG 00H
LJMP MAIN

BIN2ASCII:
	USING 0
	PUSH PSW
	PUSH AR0
	PUSH AR1
	PUSH 50H
	MOV R0, 51H
	MOV R1, 52H
		BIN2ASCII_LOOP:
		MOV A, @R0
		DA A
		ANL A, #0F0H
		SWAP A
		ADD A, #30H
		XCH A, @R1
		INC R1

		MOV A, @R0
		DA A
		ANL A, #00FH
		ADD A, #30H
		XCH A, @R1
		INC R1
		
		INC R0			
		DJNZ 50H, BIN2ASCII_Loop
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