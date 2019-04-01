;  Program to find ASCII of byte where higher 
;  nibble is in A and lower nibble is in B
	ORG 0
	LJMP MAIN

;  subroutine to convert byte to ASCII
	ORG 200H

ASCIICONV: 
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
	RET

ALPHA2:
	MOV A, R3
	ADD A, #37H	; Alphabet to ASCII
	RET

; Main program
	ORG 400H
MAIN: 
	MOV A, #0FFH
	LCALL ASCIICONV
HERE:
	SJMP HERE
	END
