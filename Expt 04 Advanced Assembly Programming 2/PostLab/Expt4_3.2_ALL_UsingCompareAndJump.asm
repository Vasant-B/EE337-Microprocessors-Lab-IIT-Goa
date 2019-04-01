;VASANT		Experiment 04 LabWork	30th Aug 2018
;Based on Exp 3 Lab Work

ORG 00H
LED EQU P1
LJMP MAIN
;----------------------------------------------------------------
ZEROOUT:
	USING 0
	PUSH PSW
	PUSH AR0
	PUSH AR1
	MOV R0, 50H		;The number N
	MOV R1, 51H		;The Pointer P
	ZEROOUT_SubLoop1:
		MOV @R1, #00H
		INC R1
		DJNZ R0, ZEROOUT_SubLoop1
	POP AR1
	POP AR0
	POP PSW
RET
;-----------------------------------------------------------------
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
		DJNZ 50H, BIN2ASCII_LOOP
	POP 50H
	POP AR1
	POP AR0
	POP PSW
RET
;------------------------------------------------------------------
MEMCPY:
	USING 0
	PUSH PSW
	PUSH AR0
	PUSH AR1

	STORE_DATA:
		MOV A, 51H
		ADD A, 50H
		DEC A
		MOV R0, A
		MOV B, 50H
		LOOP_STORE_DATA:
			MOV 01H, @R0
			PUSH 01H
			DEC R0
		DJNZ B, LOOP_STORE_DATA

	WRITE_DATA:
		MOV R0, 52H
		MOV B, 50H
		LOOP_WRITE_DATA:
			POP 01H
			MOV @R0, 01H
			INC R0
		DJNZ B, LOOP_WRITE_DATA

	POP AR1
	POP AR0
	POP PSW
RET
;---------------------------------------------------------------
DELAY_Dby20:
	USING 0
	PUSH PSW
	PUSH AR1
	PUSH AR2
	PUSH B
	MOV B, 4FH
	DELAY50ms:
		MOV R2, #200 ;-------HAS TO BE CHANGED TO #200 (decimal)
		BACK1:
			MOV R1, #0FFH
			BACK2:
			DJNZ R1, BACK2
		DJNZ R2, BACK1
	DJNZ B, DELAY50ms
	POP B
	POP AR2
	POP AR1
	POP PSW
RET
;----------------------------------------------------------------
DELAY_D:
		USING 0
		PUSH PSW
		PUSH B
		MOV B, #20
		TIMES20:
		LCALL DELAY_Dby20
		DJNZ B, TIMES20
		POP B
		POP PSW
RET
;----------------------------------------------------------------
DISPLAY:
	USING 0
	PUSH PSW
	PUSH AR0
	PUSH AR1
	MOV R0, 50H		;The number N
	MOV R1, 51H		;The Pointer P
	DISPLAY_SubLoop1:
		MOV A, @R1
		ANL A, #0FH	;And A with 0F to get just the first nibble
		SWAP A ;Swap LSB And MSB
		MOV LED, A
		LCALL DELAY_D		
		INC R1
	DJNZ R0, DISPLAY_SubLoop1
	POP AR1
	POP AR0
	POP PSW
RET 
;---------------------------------------------------------------
MAIN: 
	MOV SP, #0CFH ; Initialize the stack pointer

	;Pseudo Input
	MOV 10H, #91H
	MOV 11H, #39H
	MOV 12H, #00H
	MOV 13H, #03H
	MOV 14H, #50H
	MOV 15H, #22H
	MOV 16H, #55H

	MOV 50H, #07  ; No. of memory locations of Array P1 
	MOV 51H, #20H ; Array P1 start location 
	LCALL ZEROOUT ; Clear memory

	MOV 50H, #14  ; No. of memory locations of Array P2 
	MOV 51H, #30H ; Array P2 start location 
	LCALL ZEROOUT ; Clear memory
			
	MOV 50H, #07    ; No. of memory locations of source array 
	MOV 51H, #10H   ; Source array start location 
	MOV 52H, #20H   ; Destination array (P1) start location 
	LCALL BIN2ASCII ; Write to memory locations

	MOV 50H, #05  ; No. of elements of Array P1 to be copied in Array P2 
	MOV 51H, #20H ; Array P1 start location 
	MOV 52H, #30H ; Array P2 start location 
	LCALL MEMCPY  ; Copy block of memory to other location

	MOV 50H, #05  ; No. of memory locations of Array P2 
	MOV 51H, #30H ; Array P2 start location 
	MOV 4FH, #01  ; User defined delay value ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	LCALL DISPLAY ; Display the last four bits of elements on LEDs

IDLE: SJMP IDLE ; Perpetual loop
END