LCD_DATA EQU P2    ;LCD Data port
LCD_RS   EQU P0.0  ;LCD Register Select
LCD_RW   EQU P0.1  ;LCD Read/Write
LCD_EN   EQU P0.2  ;LCD Enable

ORG 00H
LJMP MAIN

ORG 0003H
LCALL ISS_INT0
RETI

ORG 000BH
LCALL ISS_T0
RETI

ORG 100H

ISS_INT0:
	MOV A, #0C9H
	LCALL LCD_COMMAND

	MOV A, R6
	LCALL ASCIICONV
	LCALL LCD_SENDDATA
	MOV A, B
	LCALL LCD_SENDDATA

	MOV A, TH0; R5
	LCALL ASCIICONV
	LCALL LCD_SENDDATA
	MOV A, B
	LCALL LCD_SENDDATA

	MOV A, TL0;R4
	LCALL ASCIICONV
	LCALL LCD_SENDDATA
	MOV A, B
	LCALL LCD_SENDDATA

	MOV R6, #00H
	MOV TL0, #00H
	MOV TH0, #00H


	RET
//	JNB P3.2, ISS_INT0_1
//		//INC R7
//		//RET
//		RET
//	ISS_INT0_1:
//		;LCALL DELAY_1s
//		MOV R6, #00H
//		MOV TH0, #00H
//		MOV TL0, #00H
//		//LCALL CLR_COUNT
//		RET
		//MOV R7, #00H
		//RET
;--------------------------------------------
ISS_T0:
	MOV A, P3
	ANL A, #04H
	JNZ ISS_T0_1
		RET
//		MOV A, #0C9H
//		LCALL LCD_COMMAND
//
//		MOV A, R6
//		LCALL ASCIICONV
//		LCALL LCD_SENDDATA
//		MOV A, B
//		LCALL LCD_SENDDATA
//	
//		MOV A, TH0; R5
//		LCALL ASCIICONV
//		LCALL LCD_SENDDATA
//		MOV A, B
//		LCALL LCD_SENDDATA
//	
//		MOV A, TL0;R4
//		LCALL ASCIICONV
//		LCALL LCD_SENDDATA
//		MOV A, B
//		LCALL LCD_SENDDATA
//		RET
	ISS_T0_1:
		//LCALL INC_COUNT
		INC R6
		RET

//	MOV A,R5
//	MOV TL0,A
//	MOV A,R4
//	MOV TH0,A 
//	CJNE R7,#00H,INT
//	mov r7,#00h
//	CPL TR0
//	RET
//	INT:
//	MOV A,R7	;r6 has the count value
//	mov r6,a
//	mov r7,#00h
//	CPL TR0
//	RET
;--------------------------------------------
INC_COUNT:
	INC R4
	CJNE R4, #0FFH, INC_COUNT_Continue1
	INC_COUNT_Continue1:
	JC INC_COUNT_Continue2
		MOV R4, #00
		INC R5
		CJNE R5, #0FFH, INC_COUNT_Continue3
		INC_COUNT_Continue3:
		JC INC_COUNT_Continue4
			MOV R5, #00
			INC R6
			CJNE R6, #0FFH, INC_COUNT_Continue5
			INC_COUNT_Continue5:
			JC INC_COUNT_Continue6
				MOV R6, #00
			INC_COUNT_Continue6:
		INC_COUNT_Continue4:
	INC_COUNT_Continue2:
RET
;-----------------------------------------------
CLR_COUNT:
	MOV R4, #00H
	MOV R5, #00H
	MOV R6, #00H
RET
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
DELAY_halfsecond:
	USING 0
	PUSH AR0
	PUSH AR1
	PUSH AR2

	MOV R0,#10H
	MOV R1,#200
	MOV R2,#0FFH
	DELAY_halfsecond_LOOP:
		DJNZ R2,DELAY_halfsecond_LOOP
		DJNZ R1,DELAY_halfsecond_LOOP
		DJNZ R0,DELAY_halfsecond_LOOP

	POP AR2
	POP AR1
	POP AR0
RET
;--------------------------------------------------------------------
MAIN:
	MOV P1, #0FH
	MOV IE, #83H
	MOV TMOD ,#00001001B;
	MOV TCON,#01H
	MOV TL0, #00H
	MOV TH0, #00H
	CLR TR0

	MOV R4, #00H
	MOV R5, #00H
	MOV R6, #00H
	MOV R7, #00H

//BACK:
	LCALL LCD_INIT

	MOV A, #80H
	LCALL LCD_COMMAND
	MOV DPTR, #STRING_PW_IS
	LCALL LCD_SENDSTRING

	MOV A, #0C0H
	LCALL LCD_COMMAND
	MOV DPTR, #STRING_COUNTIS
	LCALL LCD_SENDSTRING

	MOV A, #0C9H
	LCALL LCD_COMMAND

	MOV A, R6
	LCALL ASCIICONV
	LCALL LCD_SENDDATA
	MOV A, B
	LCALL LCD_SENDDATA

	MOV A, TH0; R5
	LCALL ASCIICONV
	LCALL LCD_SENDDATA
	MOV A, B
	LCALL LCD_SENDDATA

	MOV A, TL0;R4
	LCALL ASCIICONV
	LCALL LCD_SENDDATA
	MOV A, B
	LCALL LCD_SENDDATA
	
	SETB TR0

HERE:
////	LCALL INC_COUNT
//
//	MOV A, #0C9H
//	LCALL LCD_COMMAND
//
//	//LCALL DELAY_halfsecond
//	CPL P1.7
//
//	MOV A, P3
//	ANL A, #04H
//	JZ HERE
//
//	MOV A, R6
//	LCALL ASCIICONV
//	LCALL LCD_SENDDATA
//	MOV A, B
//	LCALL LCD_SENDDATA
//
//	MOV A, TH0; R5
//	LCALL ASCIICONV
//	LCALL LCD_SENDDATA
//	MOV A, B
//	LCALL LCD_SENDDATA
//
//	MOV A, TL0;R4
//	LCALL ASCIICONV
//	LCALL LCD_SENDDATA
//	MOV A, B
//	LCALL LCD_SENDDATA
LJMP HERE
	



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
STRING_PW_IS:
	DB	"PULSE WIDTH     ", 00H
STRING_COUNTIS:
	DB 	"COUNT IS ", 00H

END