;Vasant		2018-09-30
;Experiment 7 	LabWork;;

;2 Use timer T1 to debounce the switches on the Pt-51 board. 
;	Program T1 for a delay of 20ms. Read the switch twice at intervals of 20ms.
;	Reject the new value if it is different and re-read after another 20ms. 
;	If two values are the same, accept it and report it as the switch status.

SW0 EQU P1.0
SW1 EQU P1.1
SW2 EQU P1.2

ORG 0000H
LJMP MAIN
;-----------------------------------------------------------------------
;Interrupts

;ISS For T1 Overflow
ORG 001BH
	MOV 51H, 50H
	MOV A, P1
	ANL A, #0FH
	MOV 50H, A
RETI
;-------------------------------------------------------------------------
ORG 0300H

READ_SWITCHES:
	MOV A, P1
	ANL A, #0FH
	MOV 50H, A

	MOV TH1, #063H
	MOV TL1, #0BFH
	CLR TF1
	SETB TR1

	READ_SWITCHES_LOOP1:
		JNB TF1, READ_SWITCHES_LOOP1
	CLR TF1
	CLR TR1
	
	MOV A, 50H
	CJNE A, 51H, READ_SWITCHES
	MOV 52H, A
	SWAP A
	ORL A, #0FH
	MOV P1, A
RET
;-------------------------------------------------------------------------
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
MAIN:
	MOV SP, #0CFH
	;Initialize LEDs and Switches
	MOV A, #0FH
	MOV P1, A
	
	;To get the maximum possible delay from T0, Use mode 1 and Set to 00 00H
	;To get a delay of 20ms, we have to take 40000 counts, ie, Set to 63 BFH
	;First Enable Interupts for T0 and T1
	SETB EA
	CLR  ES
	SETB ET1
	CLR  EX1
	CLR  ET0
	CLR  EX0
	;SETB PT1    ;<<<<<<<<<<<<<<<<<<<<<<<<<<<I am giving a Lesser priority to the clock incrementing, than the Readswitch
	;Now, configure the Timer 0 as mentioned in the question
	;If the Gate Flag is cleared, the counter is enabled by the TR Flag alone.
	;If the Gate Flag is set, counting also requires the corresponding external interrupt pin in P3 to be HIGH
	;Set Gate to 0 and Set mode to 1
	; 	as we want a timer from T0, we have to clear C/T0
	;TMOD= G1, C/T1, T1M1, T1M0, G0, C/T0, T0M1, T0M0
	MOV A, #00010000B
	MOV TMOD, A
	;Initialize Current  Value of switch at 50H
	MOV 50H, #00H
	;Initialize Previous Value of switch at 51H
	MOV 51H, #01H
	;Initialize Correct  Value of switch at 52H
	MOV 52H, #0FFH
	
	LCALL READ_SWITCHES
	NOP
	LOOP:
		LCALL READ_SWITCHES
		SJMP LOOP
		
HERE: SJMP HERE

END