;Vasant 16th Aug 2018  
;Experiment 02  Subtracting 16bit numbers in the 2s complement form
;Revised and Inspired by Sanila Ma'am's Idea

ORG 0000H
LJMP MAIN

SUBTRACTOR_16BIT:
	CLR C
	MOV A, @R0	;it is already R0+1
	SUBB A, @R1	;R1+1
	INC R0	  	;R0+2
	INC R0	  	;R0+3
	INC R0	  	;R0+4
	MOV @R0, A
	DEC R0	;R0+3
	DEC R0	;R0+2
	DEC R0	;R0+1
	DEC R0	;R0
	DEC R1	;R1
	MOV A, @R0
	SUBB A, @R1
	INC R0		;R0+1
	INC R0		;R0+2
	INC R0		;R0+3
	MOV @R0, A
	DEC R0		;R0+2 	
	MOV A, R2
	SUBB A, R3
	ANL A, #01H
	MOV @R0, A 

RETURN:	RET
INIT:	RET
		ORG 0100H

MAIN: 
	MOV SP,#0CFH	;Move SP to an ID RAM location
	MOV R0, #30H
	MOV R1, #40H
	MOV @R0, #0FFH	;MSB of 1st number
	MOV @R1, #07FH	;MSB of 2nd Number	
	MOV A, @R0		;Step 1 of Sampling Sign from Num 1
	ANL A, #80H		;Step 2 of Sampling Sign from Num 1
	RL A			;Step 3 of Sampling Sign from Num 1
	MOV R2, A		;Step 4 of Sampling Sign from Num 1
	MOV A, @R1		;Step 1 of Sampling Sign from Num 2
	ANL A, #80H		;Step 2 of Sampling Sign from Num 2
	RL A			;Step 3 of Sampling Sign from Num 2
	MOV R3, A		;Step 4 of Sampling Sign from Num 2
	INC R1
	INC R0
	MOV @R0, #0F9H	;LSB of 1st number
	MOV @R1, #0FFH	;LSB of 2nd Number
	ACALL SUBTRACTOR_16BIT
END
