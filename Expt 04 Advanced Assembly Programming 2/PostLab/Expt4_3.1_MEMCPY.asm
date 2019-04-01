;VASANT		Experiment 04 LabWork	30th Aug 2018

ORG 00H
LJMP MAIN
;----------------------------------------------------------------
MEMCPY:
	MOV SP, #0CFH
	USING 0
	PUSH PSW
	PUSH AR0
	PUSH AR1

	STORE_DATA:
		MOV A, 51H
		ADD A, 50H
		DEC A
		MOV R0, A
		MOV B, 50H
		LOOP_STORE_DATA:
			MOV 01H, @R0
			PUSH 01H
			DEC R0
		DJNZ B, LOOP_STORE_DATA

	WRITE_DATA:
		MOV R0, 52H
		MOV B, 50H
		LOOP_WRITE_DATA:
			POP 01H
			MOV @R0, 01H
			INC R0
		DJNZ B, LOOP_WRITE_DATA

	POP AR1
	POP AR0
	POP PSW
RET
;----------------------------------------------------------------
MAIN:
	;testing Memcpy
	MOV 50H, #10		;Number N
	MOV 51H, #65H	;P1 (source)
	MOV 52H, #60H	;P2 (destination)

	MOV 65H, #01
	MOV 66H, #02
	MOV 67H, #03
	MOV 68H, #04
	MOV 69H, #05
	MOV 6AH, #06
	MOV 6BH, #07
	MOV 6CH, #08
	MOV 6DH, #09
	MOV 6EH, #10
	

	LCALL MEMCPY

END	