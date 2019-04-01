;VASANT 22nd Aug 2018
;Exp 3, lab work part 2, Zeroout

LED EQU P1
SWITCHES EQU P1
ORG 00H
LJMP MAIN
;----------------------------------------------------------------
ORG 50H
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
DELAY_1S:
	USING 0
	PUSH AR1			; For 1 second delay
	PUSH AR2
	PUSH AR3
	MOV R3, #20			; 20 iterations of 50ms

BACK2:
	MOV R2, #200

BACK1:
	MOV R1, #0FFH

BACK:
	DJNZ R1, BACK
	DJNZ R2, BACK1
	DJNZ R3, BACK2
	POP AR3
	POP AR2
	POP AR1
	RET
;-----------------------------------------------------------------
READNIBBLE:
	PUSH ACC
	ORL SWITCHES, #0FH	; 1 for input
	MOV A, SWITCHES		; Read switches
	ANL A, #0FH
	MOV 4FH, A
	POP ACC
	RET
;------------------------------------------------------------------
MAIN:
;TESTING THE ZEROOUT SUBROUTINE
	MOV 10H, #33H
	MOV 11H, #33H
	MOV 12H, #33H
	MOV 13H, #33H
	MOV 14H, #33H
	MOV 15H, #33H
;	MOV 50H, #06H
	MOV 51H, #10H
	
	MOV A, #0FH
	MOV P1, A
	MOV A, #0FFH
	MOV P1, A
	LCALL DELAY_1s
	LCALL DELAY_1s
	LCALL DELAY_1s
	LCALL DELAY_1s
//	MOV A, P1
//	ANL A, #0FH
//	MOV 50H, A
//	SWAP A
//	MOV P1, A
	LCALL READNIBBLE
	MOV 50H, 4FH
	MOV A, #00H
	MOV P1, A
	LCALL DELAY_1s
	LCALL DELAY_1s
	LCALL DELAY_1s
	LCALL DELAY_1s

	LCALL ZEROOUT
	MOV A, 4FH
	SWAP A
	MOV P1, A
	LCALL DELAY_1s
	LCALL DELAY_1s
	LCALL DELAY_1s
	LCALL DELAY_1s

END 


//	SWITCHES EQU P1
//	LEDS EQU P1
//
//	ORG 00H
//	LJMP MAIN
;-----------------------
//ORG 00H
//LJMP MAIN
//SWITCHES EQU P1
//	
//READNIBBLE:
//	PUSH ACC
//	ORL SWITCHES, #0FH	; 1 for input
//	MOV A, SWITCHES		; Read switches
//	ANL A, #0FH
//	MOV 4FH, A
//	POP ACC
//	RET
//	
//DELAY_1S:
//	USING 0
//	PUSH AR1			; For 1 second delay
//	PUSH AR2
//	PUSH AR3
//	MOV R3, #20			; 20 iterations of 50ms
//
//BACK2:
//	MOV R2, #200
//
//BACK1:
//	MOV R1, #0FFH
//
//BACK:
//	DJNZ R1, BACK
//	DJNZ R2, BACK1
//	DJNZ R3, BACK2
//	POP AR3
//	POP AR2
//	POP AR1
//	RET
//	
//DELAY_5S:
//	PUSH AR4
//	MOV R4, #5
//
//SEC1:
//	LCALL DELAY_1S
//	DJNZ R4, SEC1
//	POP AR4
//	RET
//	
//LED_DISPLAY:
//	PUSH ACC
//	ANL LEDS, #0FH		; 0 for output
//	MOV 4EH, A
//	SWAP A
//	ORL LEDS, A
//	LCALL DELAY_5S
//	ANL LEDS, #0FH
//	POP ACC
//
//MAIN:
//	SJMP LOOP
//
//DISP_OLD:
//	LCALL LED_DISPLAY	
//	LCALL READNIBBLE
//	MOV A, 4FH
//	CJNE A, #0FH, DISP_OLD
//	SJMP NOTFF
//
//LOOP:
//	ORL LEDS, #0F0H		; All LEDs ON
//	LCALL DELAY_5S
//	ANL LEDS, #0FH		; 0 for output
//	LCALL READNIBBLE
//
//NOTFF:
//	LCALL DELAY_1S
//	MOV A, 4FH
//	MOV 4EH, A
//	LCALL LED_DISPLAY
//	LCALL READNIBBLE
//	MOV A, 4FH
//	CJNE A, #0FH, DISP_OLD
//	SJMP MAIN
//	
//IDLE:
//	SJMP IDLE
//	
//	END
