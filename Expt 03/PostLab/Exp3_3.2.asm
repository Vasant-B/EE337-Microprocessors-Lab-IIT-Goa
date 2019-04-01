;VASANT 22nd Aug 2018
;Exp 3, lab work part 2, Zeroout

LED EQU P1
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

MAIN:
;TESTING THE ZEROOUT SUBROUTINE
	MOV 10H, #33H
	MOV 11H, #33H
	MOV 12H, #33H
	MOV 13H, #33H
	MOV 14H, #33H
	MOV 15H, #33H
	MOV 50H, #06H
	MOV 51H, #10H
	LCALL ZEROOUT
END 