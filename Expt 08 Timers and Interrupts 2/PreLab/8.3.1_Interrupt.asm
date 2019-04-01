;VASANT		
;Experiment 8 EE337		2018-10-11
LCD_DATA EQU P2    ;LCD Data port
LCD_RS   EQU P0.0  ;LCD Register Select
LCD_RW   EQU P0.1  ;LCD Read/Write
LCD_EN   EQU P0.2  ;LCD Enable
; Defining Timer-2 registers 
	T2CON  DATA 0C8H 
	T2MOD  DATA 0C9H 
	RCAP2L DATA 0CAH 
	RCAP2H DATA 0CBH
	TL2    DATA 0CCH 
	TH2    DATA 0CDH
; Defining interrupt enable (IE) bit 
	ET2    BIT  0ADH
; Defining interrupt priority (IP) bit 
	PT2    BIT  0BDH
; Defining P1 
	T2EX   BIT  91H 
	T2     BIT  90H
; Defining timer control (T2CON) register bits 
	TF2    BIT  0CFH 
	EXF2   BIT  0CEH 
	RCLK   BIT  0CDH 
	TCLK   BIT  0CCH 
	EXEN2  BIT  0CBH 
	TR2    BIT  0CAH 
	C_T2   BIT  0C9H 
	CP_RL2 BIT  0C8H

ORG 0000H 
LJMP MAIN

;ISS For Timer 2
ORG 002BH
	LJMP T2_ISS


ORG 0100H
;----------------------------------------------------------------------
;Timer-2 initialization
T2_INIT:
	MOV T2MOD, #00H
	;T2CON
	CLR TF2
	CLR EXF2
	CLR RCLK
	CLR TCLK
	CLR EXEN2 
	CLR TR2 
	CLR C_T2
	SETB CP_RL2
	;T2EX
	SETB T2EX


;Initialize values in TH2, TL2 depending on required frequency 
	MOV TH2, #00H ; Init MSB value 
	MOV TL2, #00H ; Init LSB value
;Reload values in RCAP 
	MOV RCAP2H, #00H ; Reload MSB value 
	MOV RCAP2L, #00H ; Reload LSB value 

RET
;-------------------------------------------------------------------------
T2_ISS:
	CLR TF2
	INC R0
	CJNE R0, #31, T2_ISS_CONT1
		;R0 = 31
		MOV R0, #00H
		INC R1
		CPL P1.7
		MOV A, #80H
		LCALL LCD_COMMAND
		MOV A, R1
		LCALL ASCIICONV
		LCALL LCD_SENDDATA
		MOV A, B
		LCALL LCD_SENDDATA
	T2_ISS_CONT1:
	RETI
;-------------------------------------------------------------------------
;-------------------------------------------------------------------------
;LCD Related Subroutines
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
	SUBB A, #0AH 	; Check if nibble is digit or alphabet
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
	SUBB A, #0AH
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
;--------------------------------------------------------------------
; Main starts here 
;ORG 200H
MAIN:
	MOV SP, #0D0H
 ; Port initialization
	MOV P1, #0FH
	MOV P2, #00H
	MOV P0, #00H

	;Initialize the LCD
	LCALL LCD_INIT
	
	;Enable Interrupts
	SETB EA
	SETB ET2
	
	;Initialize Timer 2 
	LCALL T2_INIT

	MOV R1, #00H
	MOV R0, #00H
	SETB TR2

	
//HERE:
		MOV A, #80H
		LCALL LCD_COMMAND
		MOV A, R0
		LCALL ASCIICONV
		LCALL LCD_SENDDATA
		MOV A, B
		LCALL LCD_SENDDATA
//	LJMP HERE
IDLE: SJMP IDLE
;----------ROM TEXT STRINGS------------------
MY_STRING1:
	DB	"EE337-7.4  CLOCK", 00H
MY_STRING2: 
	DB	"VASANT   IIT GOA", 00H
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
MY_STRING_ENTER_MEMORY:
	DB	"  ENTER MEMORY  ", 00H
MY_STRING_LOCATION:
	DB	"    LOCATION    ", 00H
MY_STRING_CLOCK:
	DB	"Time in HH:MM:SS", 00H
MY_STRING_SETTIME:
	DB	"SETTIME HH:MM:SS", 00H
END