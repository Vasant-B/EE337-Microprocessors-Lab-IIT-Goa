;Vasant		2018-09-26
;Experiment 6	Lab Work
LCD_DATA EQU P2    ;LCD Data port
LCD_RS   EQU P0.0  ;LCD Register Select
LCD_RW   EQU P0.1  ;LCD Read/Write
LCD_EN   EQU P0.2  ;LCD Enable

ORG 00H
LJMP MAIN

;------LCD Initialization-------------------
LCD_INIT:
	MOV LCD_DATA, #38H	;Function set: 2 Line, 8-bit, 5x7 dots
	CLR LCD_RS			;Select Command Register
	CLR LCD_RW			;Write Mode
	SETB LCD_EN
	LCALL DELAY
	CLR LCD_EN
	LCALL DELAY

	MOV LCD_DATA, #0CH  ;Display on, Curson off
	CLR LCD_RS			;Select Command Register
	CLR LCD_RW			;Write Mode
	SETB LCD_EN
	LCALL DELAY
	CLR LCD_EN
	LCALL DELAY

	MOV LCD_DATA, #01H  ;Clear LCD
	CLR LCD_RS			;Select Command Register
	CLR LCD_RW			;Write Mode
	SETB LCD_EN
	LCALL DELAY
	CLR LCD_EN
	LCALL DELAY

	MOV LCD_DATA, #06H  ;Entry mode, auto increment with no shift
	CLR LCD_RS			;Select Command Register
	CLR LCD_RW			;Write Mode
	SETB LCD_EN
	LCALL DELAY
	CLR LCD_EN
	LCALL DELAY
RET
;---------Command sending routine---------------
LCD_COMMAND:
	MOV LCD_DATA, A		;Move command to port
	CLR LCD_RS			;Command Register
	CLR LCD_RW			;Write Mode
	SETB LCD_EN
	LCALL DELAY
	CLR LCD_EN
	LCALL DELAY
RET
;---------Data sending routine---------------
LCD_SENDDATA:
	MOV LCD_DATA, A		;Move command to port
	SETB LCD_RS			;Data Register
	CLR LCD_RW			;Write Mode
	SETB LCD_EN
	LCALL DELAY
	CLR LCD_EN
	LCALL DELAY
	LCALL DELAY
RET
;---------------Text string sending----------------
LCD_SENDSTRING:
	CLR A
	MOVC A, @A+DPTR
	JZ LCD_SENDSTRING_EXIT
	LCALL LCD_SENDDATA
	INC DPTR
	SJMP LCD_SENDSTRING
LCD_SENDSTRING_EXIT:
RET
;------Displays B ASCII Values starting from A-----
LCD_SEND_ASCII_NAME:
		USING 0
		PUSH AR1
		MOV R1, A
		LCD_SEND_ASCII_NAME_LOOP1:
		 mov   LCD_data, @R1  ;Move the command to LCD port
         setb  LCD_rs         ;Selected data register
         clr   LCD_rw         ;We are writing
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         acall delay
		 acall delay

		 INC R1
		 DJNZ B, LCD_SEND_ASCII_NAME_LOOP1
		 POP AR1
         ret                  ;Return from busy routine
;-------Display Array of 16, pointed by A-----------
LCD_DISPLAY_ARRAY16_atA:
		USING 0
		PUSH AR0
		PUSH B
		
		MOV B, #16
		MOV R0, A			
		LCD_DISPLAY_ARRAY16_atA_LOOP:
		MOV LCD_DATA, @R0
		SETB LCD_RS
		CLR LCD_RW
		SETB LCD_EN
		LCALL DELAY
		CLR LCD_EN
		LCALL DELAY

		INC R0
		DJNZ B, LCD_DISPLAY_ARRAY16_atA_LOOP

		POP B
		POP AR0
RET
;-------------Delay---------------------------------
DELAY:
	USING 0
	PUSH AR0
	PUSH AR1
	
	MOV R1, #01
	DELAY_LOOP0:
	MOV R0, #255
	DELAY_LOOP1:
	DJNZ R0, DELAY_LOOP1
	DJNZ R1, DELAY_LOOP0

	POP AR1
	POP AR0
RET
;---------------------------------------------------------------------
;  Program to find ASCII of byte where higher 
;  nibble is in A and lower nibble is in B
;  subroutine to convert byte to ASCII
ASCIICONV:
	USING 0
	PUSH AR2
	PUSH AR3
	 
	MOV R2, A
	ANL A, #0FH
	MOV R3, A
	SUBB A, #09H 	; Check if nibble is digit or alphabet
	JNC ALPHA
	
	MOV A, R3
	ADD A, #30H   	; Add 30H to conv hex to ASCII
	MOV B, A
	JMP NEXT
	
ALPHA: 
	MOV A, R3  	; Add 37H to convert alphabet to ASCII
	ADD A, #37H
	MOV B, A

NEXT:
	MOV A, R2
	ANL A, #0F0H    ; Check higher nibble is digit or alphabet
	SWAP A
	MOV R3, A
	SUBB A, #09H
	JNC ALPHA2 
	
	MOV A, R3	; Digit to ASCII
	ADD A, #30H
	POP AR3
	POP AR2
	RET

ALPHA2:
	MOV A, R3
	ADD A, #37H	; Alphabet to ASCII
	POP AR3
	POP AR2
	RET
;-------------------------------------------------------------------------
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
LCD_DISPLAY_REGISTERS:
	
	;PUSH B>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	PUSH B
	;PUSH A>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	PUSH 0E0H

	MOV A, #80H			;Put cursor on first row,1 column
	LCALL LCD_COMMAND
	LCALL DELAY
	MOV DPTR, #MY_STRING_ABPSW
	LCALL LCD_SENDSTRING
	LCALL DELAY

	;POP A>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	POP 0E0H
	;Display A (first convert to ASCII)
	LCALL ASCIICONV
	;First, display Higher Nibble
	LCALL LCD_SENDDATA 
	LCALL DELAY
	;Now, display Lower nibble
	MOV A, B
	LCALL LCD_SENDDATA
	LCALL DELAY

	;Insert Space
	MOV DPTR, #MY_STRING_SPACEBAR
	LCALL LCD_SENDSTRING
	LCALL DELAY
	;POP B>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	POP B
	;Display B
	MOV A, B
	LCALL ASCIICONV
	;First, display Higher Nibble
	LCALL LCD_SENDDATA 
	LCALL DELAY
	;Now, display Lower nibble
	MOV A, B
	LCALL LCD_SENDDATA
	LCALL DELAY

	;Insert Space
	MOV DPTR, #MY_STRING_SPACEBAR
	LCALL LCD_SENDSTRING
	LCALL DELAY
	
	MOV A, PSW
	LCALL ASCIICONV
	;First, display Higher Nibble
	LCALL LCD_SENDDATA 
	LCALL DELAY
	;Now, display Lower nibble
	MOV A, B
	LCALL LCD_SENDDATA
	LCALL DELAY
	
	;NOW, NEXT LINE
	MOV A, #0C0H			;Put cursor on second row,0th column
	LCALL LCD_COMMAND
	LCALL DELAY
	MOV DPTR, #MY_STRING_R012
	LCALL LCD_SENDSTRING
	LCALL DELAY

	;Display R0 (first convert to ASCII)
	MOV A, R0
	LCALL ASCIICONV
	;First, display Higher Nibble
	LCALL LCD_SENDDATA 
	LCALL DELAY
	;Now, display Lower nibble
	MOV A, B
	LCALL LCD_SENDDATA
	LCALL DELAY

	;Insert Space
	MOV DPTR, #MY_STRING_SPACEBAR
	LCALL LCD_SENDSTRING
	LCALL DELAY

	;Display R1
	MOV A, R1
	LCALL ASCIICONV
	;First, display Higher Nibble
	LCALL LCD_SENDDATA 
	LCALL DELAY
	;Now, display Lower nibble
	MOV A, B
	LCALL LCD_SENDDATA
	LCALL DELAY

	;Insert Space
	MOV DPTR, #MY_STRING_SPACEBAR
	LCALL LCD_SENDSTRING
	LCALL DELAY
	
	;Display R2
	MOV A, R2
	LCALL ASCIICONV
	;First, display Higher Nibble
	LCALL LCD_SENDDATA 
	LCALL DELAY
	;Now, display Lower nibble
	MOV A, B
	LCALL LCD_SENDDATA
	LCALL DELAY
	
	
	LCALL DELAY_5s
	
	
	;NOW, NEXT PART of display registers
	MOV A, #080H			;Put cursor on first row,0th column
	LCALL LCD_COMMAND
	LCALL DELAY
	MOV DPTR, #MY_STRING_R345
	LCALL LCD_SENDSTRING
	LCALL DELAY

	;Display R3 (first convert to ASCII)
	MOV A, R3
	LCALL ASCIICONV
	;First, display Higher Nibble
	LCALL LCD_SENDDATA 
	LCALL DELAY
	;Now, display Lower nibble
	MOV A, B
	LCALL LCD_SENDDATA
	LCALL DELAY

	;Insert Space
	MOV DPTR, #MY_STRING_SPACEBAR
	LCALL LCD_SENDSTRING
	LCALL DELAY

	;Display R4
	MOV A, R4
	LCALL ASCIICONV
	;First, display Higher Nibble
	LCALL LCD_SENDDATA 
	LCALL DELAY
	;Now, display Lower nibble
	MOV A, B
	LCALL LCD_SENDDATA
	LCALL DELAY

	;Insert Space
	MOV DPTR, #MY_STRING_SPACEBAR
	LCALL LCD_SENDSTRING
	LCALL DELAY
	
	;Display R5
	MOV A, R5
	LCALL ASCIICONV
	;First, display Higher Nibble
	LCALL LCD_SENDDATA 
	LCALL DELAY
	;Now, display Lower nibble
	MOV A, B
	LCALL LCD_SENDDATA
	LCALL DELAY
	
	
	;Now, Next line of part 2
	MOV A, #0C0H			;Put cursor on second row,0th column
	LCALL LCD_COMMAND
	LCALL DELAY
	MOV DPTR, #MY_STRING_R67SP
	LCALL LCD_SENDSTRING
	LCALL DELAY

	;Display R6 (first convert to ASCII)
	MOV A, R6
	LCALL ASCIICONV
	;First, display Higher Nibble
	LCALL LCD_SENDDATA 
	LCALL DELAY
	;Now, display Lower nibble
	MOV A, B
	LCALL LCD_SENDDATA
	LCALL DELAY

	;Insert Space
	MOV DPTR, #MY_STRING_SPACEBAR
	LCALL LCD_SENDSTRING
	LCALL DELAY

	;Display R7
	MOV A, R7
	LCALL ASCIICONV
	;First, display Higher Nibble
	LCALL LCD_SENDDATA 
	LCALL DELAY
	;Now, display Lower nibble
	MOV A, B
	LCALL LCD_SENDDATA
	LCALL DELAY

	;Insert Space
	MOV DPTR, #MY_STRING_SPACEBAR
	LCALL LCD_SENDSTRING
	LCALL DELAY
	
	;Display SP
	MOV A, SP
	LCALL ASCIICONV
	;First, display Higher Nibble
	LCALL LCD_SENDDATA 
	LCALL DELAY
	;Now, display Lower nibble
	MOV A, B
	LCALL LCD_SENDDATA
	LCALL DELAY
	
	LCALL DELAY_5s

RET		
;---------------------------------------------------------------
MAIN:
	MOV SP, #0CFH

	MOV P1, #00H
	MOV P2, #00H

	;Initial Delay for LCD Power up
	LCALL DELAY
	LCALL DELAY

	LCALL LCD_INIT
	LCALL DELAY
	LCALL DELAY
	LCALL DELAY

	MOV A, #80H			;Put cursor on first row,1 column
	LCALL LCD_COMMAND
	LCALL DELAY
	MOV DPTR, #MY_STRING1
	LCALL LCD_SENDSTRING
	LCALL DELAY
	LCALL DELAY
	LCALL DELAY

	MOV A, #0C0H		;Put cursor on second row,5th column
	LCALL LCD_COMMAND
	LCALL DELAY
	MOV DPTR, #MY_STRING2
	LCALL LCD_SENDSTRING
	LCALL DELAY
	LCALL DELAY
	LCALL DELAY

	LCALL DELAY_1s

	MOV A, #80H			;Put cursor on first row,1 column
	LCALL LCD_COMMAND
	LCALL DELAY
	MOV DPTR, #MY_STRING_CLEARDISPLAY
	LCALL LCD_SENDSTRING
	LCALL DELAY
	LCALL DELAY
	LCALL DELAY

	MOV A, #0C0H		;Put cursor on second row,5th column
	LCALL LCD_COMMAND
	LCALL DELAY
	MOV DPTR, #MY_STRING_CLEARDISPLAY
	LCALL LCD_SENDSTRING
	LCALL DELAY
	LCALL DELAY
	LCALL DELAY

	LCALL DELAY

	MOV A, #0AH
	MOV B, #0BH
	MOV R0, #00H
	MOV R1, #01H
	MOV R2, #02H
	MOV R3, #03H
	MOV R4, #04H
	MOV R5, #05H
	MOV R6, #06H
	MOV R7, #07H

	LCALL LCD_DISPLAY_REGISTERS



	  
IDLE: SJMP IDLE



;----------ROM TEXT STRINGS------------------
MY_STRING1:
	DB	"EE337 6.3.1", 00H
MY_STRING2: 
	DB	"VASANT IITGoa", 00H
MY_STRING_CLEARDISPLAY:
	DB 	"                ", 00H
MY_STRING_ABPSW:
	DB	"ABPSW = ", 00H
MY_STRING_R012:
	DB	"R012  = ", 00H
MY_STRING_R345:
	DB	"R345  = ", 00H
MY_STRING_R67SP:
	DB	"R76SP = ", 00H
MY_STRING_SPACEBAR:
	DB	" ", 00H
END