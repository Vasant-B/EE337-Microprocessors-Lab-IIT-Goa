;VASANT 28th Aug 2018
;Based on Exp 3, lab work part 4 BIN2ASCII Using Decimal Adjust

ORG 00H
JMP MAIN
RP EQU 20H	;Read Pointer
WP EQU 20H	;Write Pointer

;---------------------------------------------
ORG 80H
BIN2ASCII:
	MOV SP, #0CFH
	X EQU 08H
	USING 0
	PUSH PSW
	PUSH AR0
	PUSH AR1
	PUSH X
	MOV B, #10
	STORE_DATA:
		MOV A, #RP
		ADD A, #9
		MOV R0, A
		LOOP_STORE_DATA:
		MOV X, @R0
		PUSH X
		DEC R0
		DJNZ B, LOOP_STORE_DATA
	MOV B, #00H
	MOV X, #00H

	MOV R0, #WP
	MOV B, #10
	
	BIN2ASCII_LOOP0:
	POP X
		MOV A, X
		DA A
		ANL A, #0F0H
		SWAP A
		ADD A, #30H
		XCH A, @R0
		INC R0

		MOV A, X
		DA A
		ANL A, #0FH
		ADD A, #30H
		XCH A, @R0
		INC R0
				
	DJNZ B, BIN2ASCII_LOOP0

	POP X
	POP AR1
	POP AR0
	POP PSW
RET
;------------------------------------------------
MAIN:
   ;Pseudo Input
   MOV 20H, #04AH
   MOV 21H, #039H
   MOV 22H, #091H
   MOV 23H, #019H
   MOV 24H, #020H
   MOV 25H, #045H
   MOV 26H, #049H
   MOV 27H, #050H
   MOV 28H, #022H
   MOV 29H, #018H
   LCALL BIN2ASCII
END