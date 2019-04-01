; Vasant 12th Aug 2018  Experiment 02 PreLab   Array sort

ORG 0000H
LJMP MAIN

MAIN:
	;Taking the inputs
	MOV 60H, #0FAH
	MOV 61H, #006H
	MOV 62H, #005H
	MOV 63H, #003H
	MOV 64H, #000H
	;copying stuff from 6Xh to 7Xh
	MOV 70H, 60H
	MOV 71H, 61H
	MOV 72H, 62H
	MOV 73H, 63H
	MOV 74H, 64H

	MOV 69H, #00H	 ;PSEUDO BUBBLE
	MOV 75H, #0FFH	 ;PSEUDO BUBBLE
	MOV 76H, #0FFH
	MOV 68H, #00H
	
	MOV R2, #00H	 ;Integer Indicating the count
LOOPMAIN:
	MOV R0, #70H	 ;Pointer of the position
	MOV R1, #00H	 ;Integer Indicating the count

	LOOPCOMPAREANDSWAP:
		
					COMPARE:
						;Ro is the pointer of the current bubble
						;This sub-assembly swaps R0 and (R0+1)
						CLR C
						MOV A, @R0
						INC R0
						SUBB A, @R0
						DEC R0
					
						JC SKIPSWAP1 ;IF carry(borrow) = 1, then R0-(R0+1)<0 so, no need to swap
						JNC SWAP1	 ;IF carry(borrow) = 0, then R0-(R0+1)>0 so, we need to swap
					SWAP1:
						;R0 is the pointer of the current bubble
						;This sub-assembly Swaps R0 and (R0+1)
						MOV 50H, @R0
						INC R0
						MOV 51H, @R0
						MOV @R0, 50H
						DEC R0
						MOV @R0, 51H
						CLR 50H
						CLR 51H
					SKIPSWAP1:
		INC R0
		INC R1
		CJNE R1, #05H, LOOPCOMPAREANDSWAP
		INC R2
		CJNE R2, #05H, LOOPMAIN

DELETE_UNUSED:
	MOV 75H, #00H
	MOV 76H, #00H
	MOV 69H, #00H
	MOV 68H, #00H
IDLE:
	SJMP IDLE
END