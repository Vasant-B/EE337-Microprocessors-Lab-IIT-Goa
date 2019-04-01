; ASM file to generate a square wave at P1.0 using timer 2
; Last updated by Nandakumar on 09/10/2018

; Defining Timer-2 registers

	T2CON	DATA 0C8H
	T2MOD 	DATA 0C9H
	RCAP2L 	DATA 0CAH
	RCAP2H 	DATA 0CBH
	TL2 	DATA 0CCH
	TH2 	DATA 0CDH

; Defining interrupt enable (IE) bit

	ET2 	BIT	0ADH

; Defining interrupt priority (IP) bit

	PT2 	BIT	0BDH

; Defining P1

	T2EX 	BIT 91H
	T2 		BIT 90H

; Defining timer control (T2CON) register bits

	TF2 	BIT 0CFH
	EXF2 	BIT 0CEH
	RCLK 	BIT 0CDH
	TCLK 	BIT 0CCH
	EXEN2 	BIT 0CBH
	TR2 	BIT 0CAH
	C_T2 	BIT 0C9H
	CP_RL2 	BIT 0C8H

	ORG 0000H
	LJMP MAIN

; Timer 2 ISR

	ORG 002BH
	LJMP T2_ISR			; Why should you use an LJMP here?

	ORG 0100H

; Timer-2 initialization

T2_INIT:
						; Initialize values in TH2, TL2 depending on required frequency	
	MOV TH2, #0FFH 		; Init MSB value
	MOV TL2, #0FFH 		; Init LSB value

						; Reload values in RCAP 
	MOV RCAP2H, #0FFH 	; Reload MSB value
	MOV RCAP2L, #0FFH 	; Reload LSB value
	
	MOV T2CON, #80H		; Set ofr 16-bit auto-reload mode
	SETB ET2			; Enable timer 2 interrupts
	SETB TR2			; Start timer 2
	SETB EA				; Global interrupt enable

	RET

; Timer 2 subroutine

T2_ISR:
	CPL P1.0
	CLR TF2
	RETI

; Main starts here

	ORG 200H

MAIN:
	MOV P1, #00H		; Port initialization
				
	LCALL T2_INIT 		; Timer initialization

IDLE:
	SJMP IDLE
	
	END