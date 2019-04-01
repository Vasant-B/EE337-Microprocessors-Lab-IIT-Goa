;VASANT 22nd Aug 2018
;exp 3, lab work part 3 Display Johnson Ring Counter

LED EQU P1
ORG 00H
LJMP MAIN
;-----------------------------------------------------------------
ORG 50H
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
			;Delay for 1 second:
			DELAY1s:
			PUSH PSW
			PUSH 40H
			PUSH 41H
			PUSH 42H
			MOV 42H, #20
				DELAY1s_Subloop0:
				MOV 40H, #200 ;-------HAS TO BE CHANGED TO #200 (decimal)
				DELAY1s_Subloop1:
					MOV 41H, #0FFH
					DELAY1s_Subloop2:
					DJNZ 41H, DELAY1s_Subloop2
				DJNZ 40H, DELAY1s_Subloop1
			DJNZ 42H, DELAY1s_Subloop0
			POP 42H
			POP 41H
			POP 40H
			POP PSW			
		INC R1
	DJNZ R0, DISPLAY_SubLoop1
	POP AR1
	POP AR0
	POP PSW
RET
;--------------------------------------------------------------------
MAIN:
;TESTING THE DISPLAY SUBROUTINE
	MOV 50H, #04	;The Number N
	MOV 51H, #10H	;The Pointer P

	MOV 10H, #01H
	MOV 11H, #02H
	MOV 12H, #04H
	MOV 13H, #08H
	
	LOOP_JOHNSONCOUNTER:
	LCALL DISPLAY
	;Have a breakpoint in the subroutine DISPLAY
	SJMP LOOP_JOHNSONCOUNTER
END 