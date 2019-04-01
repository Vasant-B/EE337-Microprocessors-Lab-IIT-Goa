;Vasant 2018-09-20
;Expt 5 Labwork part 2

ORG 00H
LJMP MAIN
;------------------------------------------------------------
DELAY_1S:
	USING 0
	PUSH AR1			; For 1 second delay
	PUSH AR2
	PUSH AR3
	MOV R3, #20			; 20 iterations of 50ms

DELAY_1S_BACK2:
	MOV R2, #200

DELAY_1S_BACK1:
	MOV R1, #0FFH

DELAY_1S_BACK:

	DJNZ R1, DELAY_1S_BACK
	DJNZ R2, DELAY_1S_BACK1
	DJNZ R3, DELAY_1S_BACK2
	POP AR3
	POP AR2
	POP AR1
	RET
;-----------------------------------------------------------------
DELAY_5S:
	USING 0
	PUSH AR1			; For 5 second delay
	PUSH AR2
	PUSH AR3
	MOV R3, #100			; 100 iterations of 50ms

DELAY_5S_BACK2:
	MOV R2, #200

DELAY_5S_BACK1:
	MOV R1, #0FFH

DELAY_5S_BACK:

	DJNZ R1, DELAY_5S_BACK
	DJNZ R2, DELAY_5S_BACK1
	DJNZ R3, DELAY_5S_BACK2
	POP AR3
	POP AR2
	POP AR1
	RET
;-----------------------------------------------------------------
READNIBBLE: 
; Routine to read a nibble and confirm from user
;I have removed the handshake 
;ie, confirming the input is not being done, to save time whie entering data
;I have just commented the confirming input part, that can be un-commented
		USING 0
		PUSH PSW
		PUSH AR1
		PUSH AR0
; First configure switches as input and LEDs as output 
; To configure a port as output, clear it 
; To configure a port as input, set it
		MOV A, #0FH
		MOV P1, A

; Logic to read a 4 bit number (nibble) and get confirmation from user 

READNIBBLE_LOOP:

; Turn on all 4 LEDs (routine is ready to accept input) 
		SETB p1.7
		SETB p1.6
		SETB p1.5
		SETB p1.4
; Wait for 5 seconds during which user can give input through switches
		LCALL DELAY_5s			 
; Turn off all LEDs
		CLR p1.7
		CLR p1.6
		CLR p1.5
		CLR p1.4 
; Read the input from switches (nibble)
		MOV A, P1
		ANL A, #0FH
		MOV B, A
		MOV 4EH, A 
		LCALL DELAY_5s
; Wait for one second
//		LCALL DELAY_1s
; Show the read value on LEDs
//		MOV A, B
//		SWAP A
//		MOV P1, A 
; Wait for 5 seconds
;    (during this period the user can keep all the switches to OFF position to signal that the read value is correct
;									and the routine can proceed to the next step)
//		LCALL DELAY_5s
; Clear leds
//		CLR p1.7
//		CLR p1.6
//		CLR p1.5
//		CLR p1.4 		 
//; Read the input from switches
//		MOV A, P1
//		CJNE A, #0FH, READNIBBLE_LOOP 
; If read value <> 0FH go to loop
; Return to caller with previously read nibble in location 4EH (lower 4 bits)
		;MOV 4EH, B
		POP AR0
		POP AR1
		POP PSW
RET
;---------------------------------------------------------------
PACKNIBBLES:
	USING 0
	PUSH PSW
	PUSH AR1
	PUSH AR0
	PUSH B	
	LCALL READNIBBLE
	MOV 4FH, 4EH
	LCALL READNIBBLE
	MOV A, 4FH
	SWAP A
	MOV R1, #4EH 
	XCHD A, @R1
	MOV 4FH, A 
	POP B
	POP AR0
	POP AR1
	POP PSW
RET
;---------------------------------------------------------------
READVALUES:
	USING 0
	PUSH PSW
	PUSH AR1
	PUSH AR0

	MOV R0, 50H	;Value of K
	MOV R1, 51H ;Pointer

	MOV B, 50H
	READVALUES_LOOP1:
		LCALL PACKNIBBLES
		MOV @R1, 4FH
		INC R1
	DJNZ B, READVALUES_LOOP1

	POP AR0
	POP AR1
	POP PSW
RET
;---------------------------------------------------------------
DISPLAYVALUES:
;Display 50H number of registers starting from the location pointed by 51H
	USING 0
	PUSH PSW
	PUSH AR0
	PUSH AR1
	MOV R0, 50H		;The number N
	MOV R1, 51H		;The Pointer P
	DISPLAYVALUES_MAINLOOP:
	MOV A, P1
	ANL A, #0FH
	MOV R3, A
	MOV B, 50H
	;INC B
	 
	CJNE A, B, DISPLAYVALUES_CONTINUE1
	DISPLAYVALUES_CONTINUE1:
	JC DISPLAYVALUES_CONTINUE2
			  ;CARRY = 0 ie, A>=K+1 ie, A>K
			  ;Turn of all LEDs
			  CLR P1.7
			  CLR P1.6
			  CLR P1.5
			  CLR P1.4
			  ;POP the un-popped
			  POP AR1
			  POP AR0
			  POP PSW
			  ;Return
			  RET
	DISPLAYVALUES_CONTINUE2: ;continues if C=1 ie A<K+1 ie, A<=K
		;Display Higher Nibble
		MOV A, R3
		;Index is in A
		ADD A, 51H
		;Location of the 8 bit value is in A
		MOV R0, A
		;Display Higher Nibble
		MOV A, @R0
		ANL A, #0F0H
		MOV P1, A
		;Delay for 1 seconds
		LCALL DELAY_1s
		;Display Lower Nibble
		MOV	A, @R0
		ANL A, #0FH
		SWAP A
		MOV P1, A
		;Delay for 1 seconds
		LCALL DELAY_1s

		;CLEAR DISPLAY
		MOV A, #0FH
		MOV P1, A
		LCALL DELAY_1s

		LJMP DISPLAYVALUES_MAINLOOP
	POP AR1
	POP AR0
	POP PSW
RET
;------------------------------------------------------------------------
MAIN:
	MOV SP, #0CFH ; Initialize the stack pointer 
	MOV 50H, #03 ; Set value of K 
	MOV 51H, #30H ; Array A start location 
	MOV 4FH, #00H ; Clear location 4FH 
	LCALL READVALUES
;the folowing four sets of code dispays the pattern 0001 0010 0100 1000
;to indicate that the read values has been succesfully completed
;during this, switches have to display the required index.
	MOV A, #01FH
	MOV P1, A
	LCALL DELAY_1s
	
	MOV A, #02FH
	MOV P1, A
	LCALL DELAY_1s
	
	MOV A, #04FH
	MOV P1, A
	LCALL DELAY_1s
	
	MOV A, #08FH
	MOV P1, A
	LCALL DELAY_1s

	MOV 50H, #03  ; Value of K 
	MOV 51H, #30H ; Array B start Location 
	LCALL DISPLAYVALUES; Display the last four bits of elements on LEDs

IDLE: SJMP IDLE
END