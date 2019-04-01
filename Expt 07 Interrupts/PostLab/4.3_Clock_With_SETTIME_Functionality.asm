;Vasant		2018-09-30
;Experiment 7 	LabWork;;

;2 Use timer T1 to debounce the switches on the Pt-51 board. 
;	Program T1 for a delay of 20ms. Read the switch twice at intervals of 20ms.
;	Reject the new value if it is different and re-read after another 20ms. 
;	If two values are the same, accept it and report it as the switch status.
;3. Use the debounced switches to implement a feature to set the clock.
;	If the switch SW0 is in the ON state the program should enter a time-set mode.
;		In the time-set mode every toggle on switch SW1 should advance minutes by 1,
;		while every toggle on switch SW2 should advance the hours by 1.
;	Returning switch SW0 to the OFF state should 
;		start displaying the time from the set value and the usual clock display 
;			as implemented in the earlier experiment should run.
;		In this mode check the status of switch SW0 every minute and go to the set mode if switch SW0 is ON.

LCD_DATA EQU P2    ;LCD Data port
LCD_RS   EQU P0.0  ;LCD Register Select
LCD_RW   EQU P0.1  ;LCD Read/Write
LCD_EN   EQU P0.2  ;LCD Enable

HH EQU R2
MM EQU R3
SS EQU R4

ORG 0000H
LJMP MAIN
;-----------------------------------------------------------------------
;Interrupts

;ISS For T0 Overflow
ORG 000BH
	MOV TL0, #00H
	MOV TH0, #00H
	CLR TF0
	LCALL INCREMENT_COUNTER	
RETI

;ISS For T1 Overflow
ORG 001BH
	MOV 51H, 50H
	MOV A, P1
	ANL A, #0FH
	MOV 50H, A
RETI

;-------------------------------------------------------------------------
ORG 0300H																  
CHECK_MODE:
	LCALL READ_SWITCHES
	MOV A, 52H
	ANL A, #01H
	JNZ TIME_SET_MODE
	JZ RUN_TIME_MODE
	TIME_SET_MODE:
		;Display SETTIME on the screen
		MOV A, #80H
		LCALL LCD_COMMAND
		LCALL DELAY
		MOV DPTR, #MY_STRING_SETTIME
		LCALL LCD_SENDSTRING
		LCALL DELAY
		
		;Disable Interupts from T0
		CLR ET0

		LCALL SET_TIME

		;Enable Interupts from T0
		SETB ET0

		MOV A, #80H
		LCALL LCD_COMMAND
		LCALL DELAY
		MOV DPTR, #MY_STRING_CLOCK
		LCALL LCD_SENDSTRING
		LCALL DELAY
		
	RET
	RUN_TIME_MODE:
		LCALL ADVANCE_TIME_by_a_unit
	RET
;-------------------------------------------------------------------------
SET_TIME:
	LOOP_SET_TIME:
	;Check if there is a Change
	LCALL READ_SWITCHES
	MOV 53H, 52H
	SETB P1.7
	LCALL DELAY_1s
	CLR P1.7
	LCALL READ_SWITCHES
	MOV A, 52H
	XRL A, 53H
	MOV 54H, A
	;Check if there is a change in the Hours
		MOV A, 54H
		ANL A, #04H
		JZ LOOP_SET_TIME_NO_CHANGE_IN_HOURS
			LCALL ADVANCE_HH_by_a_unit
		LOOP_SET_TIME_NO_CHANGE_IN_HOURS:
	;Check if there is a change in the minutes
		MOV A, 54H
		ANL A, #02H
		JZ LOOP_SET_TIME_NO_CHANGE_IN_MINUTES
			LCALL ADVANCE_MM_by_a_unit
		LOOP_SET_TIME_NO_CHANGE_IN_MINUTES:
	LCALL FORMAT_TIME_FOR_DISPLAY

;;;;Display the time too!
	LCALL DISPLAY_TIME

;;;;Keep in the set time mode or go out?
	MOV A, 52H
	ANL A, #01H
	JNZ LOOP_SET_TIME
RET

;-------------------------------------------------------------------------
READ_SWITCHES:
	;Read Switches
	MOV A, P1
	ANL A, #0FH
	MOV 50H, A
	;Set The timer 1 and Run
	MOV TH1, #063H
	MOV TL1, #0BFH
	CLR TF1
	SETB TR1
	;Wait for Switches to be sampled
	READ_SWITCHES_LOOP1:
		JNB TF1, READ_SWITCHES_LOOP1
	CLR TF1
	CLR TR1
	;Compare the Sampled Switches
	MOV A, 50H
	CJNE A, 51H, READ_SWITCHES
	;Store the Debounced Switches Value to 52H
	MOV 52H, A
	;Show  the Debounced Switches Value at the LEDs
	SWAP A
	ORL A, #0FH
	MOV P1, A
RET
;-------------------------------------------------------------------------
INCREMENT_COUNTER:
	INC R5
	CJNE R5, #32, INCREMENT_COUNTER_continue1
	INCREMENT_COUNTER_continue1:
	JC INCREMENT_COUNTER_continue2
		MOV R5, #00H
		LCALL CHECK_MODE
	INCREMENT_COUNTER_continue2:
RET
;-------------------------------------------------------------------------
ADVANCE_TIME_by_a_unit:
	INC SS
	CJNE SS, #60, ADVANCE_TIME_by_a_unit_Continue1
	ADVANCE_TIME_by_a_unit_Continue1:
	JC ADVANCE_TIME_by_a_unit_Continue2
		;Reset Seconds and Increment Minutes
		MOV SS, #00
		ADVANCE_MM_by_a_unit:
		INC MM
		CJNE MM, #60, ADVANCE_TIME_by_a_unit_Continue3
		ADVANCE_TIME_by_a_unit_Continue3:
		JC ADVANCE_TIME_by_a_unit_Continue4
			;Reset Minutes and Increment Hours
			;MOV A, MM
			;CLR C
			;SUBB A, #60
			MOV MM, #00
			ADVANCE_HH_by_a_unit:
			INC HH
			CJNE HH, #13, ADVANCE_TIME_by_a_unit_Continue5
			ADVANCE_TIME_by_a_unit_Continue5:
			JC ADVANCE_TIME_by_a_unit_Continue6
				;Reset Hours
				;MOV A, HH
				;CLR C
				;SUBB A, #12
				;MOV HH, A
				MOV HH, #01
			ADVANCE_TIME_by_a_unit_Continue6:
		ADVANCE_TIME_by_a_unit_Continue4:
	ADVANCE_TIME_by_a_unit_Continue2:
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
;--------------------------------------------------------------------
FORMAT_TIME_FOR_DISPLAY:
;A has a value between XY : 0 to 60 (decimal) or 00H to 3CH
; this should be converted such that X is in A and Y in B 
	USING 0
	PUSH AR6
	PUSH AR7
		MOV B, A
		MOV R6, #00H
		MOV R7, #00H
		JZ FORMAT_TIME_FOR_DISPLAY_continue0
		FORMAT_TIME_FOR_DISPLAY_Loop0:
			INC R6
			CJNE R6, #10, FORMAT_TIME_FOR_DISPLAY_continue1
			FORMAT_TIME_FOR_DISPLAY_continue1:
			JC FORMAT_TIME_FOR_DISPLAY_continue2
				MOV R6, #00H
				INC R7	
			FORMAT_TIME_FOR_DISPLAY_continue2:
		DJNZ B, FORMAT_TIME_FOR_DISPLAY_Loop0
		FORMAT_TIME_FOR_DISPLAY_continue0:
		MOV A, R6
		ADD A, #30H
		MOV B, A
		MOV A, R7
		ADD A, #30H		
	POP AR7
	POP AR6
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
;-------------------------------------------------------------------------
DISPLAY_TIME:	
	MOV A, #0C0H
	LCALL LCD_COMMAND
	LCALL DELAY
	LCALL DELAY
	
	;Send Hours
	MOV A, HH
	LCALL FORMAT_TIME_FOR_DISPLAY
	LCALL LCD_SENDDATA
	LCALL DELAY
	MOV A, B
	LCALL LCD_SENDDATA
	LCALL DELAY
	;Display ':'
	MOV A, #3AH
	LCALL LCD_SENDDATA
	LCALL DELAY
	;Send Minutes
	MOV A, MM
	LCALL FORMAT_TIME_FOR_DISPLAY
	LCALL LCD_SENDDATA
	LCALL DELAY
	MOV A, B
	LCALL LCD_SENDDATA
	LCALL DELAY
	;Display ':'
	MOV A, #3AH
	LCALL LCD_SENDDATA
	LCALL DELAY
	;Send Seconds
	MOV A, SS
	LCALL FORMAT_TIME_FOR_DISPLAY
	LCALL LCD_SENDDATA
	LCALL DELAY
	MOV A, B
	LCALL LCD_SENDDATA
	LCALL DELAY
RET
;-------------------------------------------------------------------------
MAIN:
	MOV SP, #0CFH
	
	;To get the maximum possible delay from T0, Use mode 1 and Set to 00 00H
	;First Enable Interupts for T0
	SETB EA
	CLR  ES
	SETB ET1
	CLR  EX1
	SETB ET0
	CLR  EX0
	SETB PT1
	;Now, configure the Timer 0 as mentioned in the question
	;If the Gate Flag is cleared, the counter is enabled by the TR Flag alone.
	;If the Gate Flag is set, counting also requires the corresponding external interrupt pin in P3 to be HIGH
	;Set Gate to 0 and Set mode to 1
	; 	as we want a timer from T0, we have to clear C/T0
	;TMOD= G1, C/T1, T1M1, T1M0, G0, C/T0, T0M1, T0M0
	MOV A, #00010001B
	MOV TMOD, A
	;Initialize the WATCH
	MOV HH, #05
	MOV MM, #58
	MOV SS, #50
	;Initialize the counter R0
	MOV R5, #00H
	;Inititalize the Timer 0 and Run
	MOV TL0, #00H
	MOV TH0, #00H
	CLR TF0
	;SETB TR0 <<<<<<<<<<<<<<<<<Doing this after the Display is ready to display the time

	;Code DISPLAY HH:MM:SS on the LCD
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
	;Display Name, Question for a while
	LCALL DELAY_1s
	LCALL DELAY_1s

	;Clear the DISPLAY
	MOV A, #01H
	LCALL LCD_COMMAND
	LCALL DELAY	

	MOV A, #80H			;Put cursor on first row,1 column
	LCALL LCD_COMMAND
	LCALL DELAY
	MOV DPTR, #MY_STRING_CLOCK
	LCALL LCD_SENDSTRING
	LCALL DELAY
	LCALL DELAY
	LCALL DELAY

	;Now, run the clock
	SETB TR0
;Loop to display the time:
BACK:
		
LCALL DISPLAY_TIME
LJMP BACK

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