;Vasant		2018-09-30
;Experiment 7 	Prelab

;Program timer T0 to generate the maximum possible delay and trigger an interrupt on time-out.
;The interrupt service routine should increment a counter till it reaches a count of 40.
;Every time the count reaches 40, an LED should be toggled and the count should be reset to 0.
;By measuring the time taken by the LED to toggle 20 times 
;	adjust the timer count such that the toggle time is as close to 1 second as possible.
;	(20 toggles should take 20 seconds).
;		If each toggle should take 1 second, time period should be two seconds, as it should have 2 toggles in one period

ORG 00H
LJMP MAIN
;-----------------------------------------------------------------------
;Interrupt Subroutine Services

;ISS For T0 Overflow
ORG 000BH
	MOV TL0, #00H
	MOV TH0, #00H
	CLR TF0
	ACALL INCREMENT_COUNTER	
RETI

;-------------------------------------------------------------------------
ORG 0300H
INCREMENT_COUNTER:
	INC R5
	CJNE R5, #31, INCREMENT_COUNTER_continue1
	INCREMENT_COUNTER_continue1:
	JC INCREMENT_COUNTER_continue2
		MOV R5, #00H
		CPL P1.7	
	INCREMENT_COUNTER_continue2:
RET
;-------------------------------------------------------------------------
MAIN:
	MOV SP, #0CFH
	;Initialize LEDs and Switches
	MOV A, #0FH
	MOV P1, A
	CLR P1.7
	;To get the maximum possible delay from T0, Use mode 1 and Set to 00 00H
	;First Enable Interupts for T0
	SETB EA
	CLR  ES
	CLR  ET1
	CLR  EX1
	SETB ET0
	CLR  EX0
	;SETB PT1
	;Now, configure the Timer 0 as mentioned in the question
	;If the Gate Flag is cleared, the counter is enabled by the TR Flag alone.
	;If the Gate Flag is set, counting also requires the corresponding external interrupt pin in P3 to be HIGH
	;Set Gate to 0 and Set mode to 1
	; 	as we want a timer from T0, we have to clear C/T0
	;TMOD= G1, C/T1, T1M1, T1M0, G0, C/T0, T0M1, T0M0
	MOV A, #00000001B
	MOV TMOD, A

	;Initialize the counter R0
	MOV R5, #00H
	;Set the timer and Run
	MOV TL0, #00H
	MOV TH0, #00H
	CLR TF0
	SETB TR0

HERE: SJMP HERE
END