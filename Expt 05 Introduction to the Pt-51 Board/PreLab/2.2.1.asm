;Vasant
;2018-09-19

;VASANT 22nd Aug 2018
;Exp 3, lab work part 1	Blinking a LED at P1.7 at a certian frequency

LED EQU P1
ORG 00H
LJMP MAIN
;---------------------------------------------------------------
DELAY_Dby20:
	USING 0
	PUSH PSW
	PUSH AR1
	PUSH AR2
	PUSH 30H
	MOV 30H, @R0
	DELAY50ms:
		MOV R2, #200 ;-------HAS TO BE CHANGED TO #200 (decimal)
		BACK1:
			MOV R1, #0FFH
			BACK2:
			DJNZ R1, BACK2
		DJNZ R2, BACK1
	DJNZ 30H, DELAY50ms
	POP 30H
	POP AR2
	POP AR1
	POP PSW
RET
;----------------------------------------------------------------
DELAY_Dby2:
		USING 0
		PUSH PSW
		PUSH 31H
		MOV 31H, #10
		TIMES10:
		LCALL DELAY_Dby20
		DJNZ 31H, TIMES10
		POP 31H
		POP PSW
RET
;-----------------------------------------------------------------
MAIN:
	MOV R0, #4FH	;The location that D is stored
	MOV @R0, #05	;The value of D	(Timeperiod in seconds)
	MOV LED, #00H
	BACK:
		MOV LED, #80H
		LCALL DELAY_Dby2
		MOV LED, #00H
		LCALL DELAY_Dby2
		SJMP BACK
END 