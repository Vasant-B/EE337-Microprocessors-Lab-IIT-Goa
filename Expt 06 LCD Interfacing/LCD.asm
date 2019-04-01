; This subroutine writes characters on the LCD

	LCD_DATA EQU P2    	; LCD data port
	LCD_RS   EQU P0.0  	; LCD register select
	LCD_RW   EQU P0.1  	; LCD read/write
	LCD_EN   EQU P0.2  	; LCD enable

	ORG 0000H
	LJMP MAIN

; LCD initialisation routine

LCD_INIT:
	MOV   LCD_DATA, #38H 	; Function set: 2 line,  8-bit,  5x7 dots
	CLR   LCD_RS         	; Selected command register
	CLR   LCD_RW         	; We are writing in instruction register
	SETB  LCD_EN         	; Enable H->L
        ACALL DELAY
	CLR   LCD_EN
    	ACALL DELAY
	
	MOV   LCD_DATA, #0CH 	; Display on,  curson off
	CLR   LCD_RS         	; Selected instruction register
	CLR   LCD_RW         	; We are writing in instruction register
	SETB  LCD_EN         	; Enable H->L
        ACALL DELAY
	CLR   LCD_EN
	
        ACALL DELAY
	MOV   LCD_DATA, #01H 	; Clear LCD
	CLR   LCD_RS         	; Selected command register
	CLR   LCD_RW         	; We are writing in instruction register
	SETB  LCD_EN         	; Enable H->L
        ACALL DELAY
	CLR   LCD_EN
	
        ACALL DELAY
	
	MOV   LCD_DATA, #06H 	; Entry mode,  auto increment with no shift
	CLR   LCD_RS         	; Selected command register
	CLR   LCD_RW         	; We are writing in instruction register
	SETB  LCD_EN         	; Enable H->L
        ACALL DELAY
	CLR   LCD_EN
	
        ACALL DELAY
	
	RET                  	; Return from routine

; Command sending routine

 LCD_COMMAND:
 	MOV   LCD_DATA, A    	; Move the command to LCD port
 	CLR   LCD_RS         	; Selected command register
 	CLR   LCD_RW         	; We are writing in instruction register
 	SETB  LCD_EN         	; Enable H->L
        ACALL DELAY
 	CLR   LCD_EN
        ACALL DELAY
 	
 	RET  

; Data sending routine

 LCD_SENDDATA:
         MOV   LCD_DATA, A    	; Move the command to LCD port
         SETB  LCD_RS         	; Selected data register
         CLR   LCD_RW         	; We are writing
         SETB  LCD_EN         	; Enable H->L
	 ACALL DELAY
         CLR   LCD_EN
         ACALL DELAY
	 ACALL DELAY

         RET                  	; Return from busy routine

; Text strings sending routine

LCD_SENDSTRING:
	PUSH  0E0H
	CLR   A                 ; Clear accumulator for any previous data
	MOVC  A, @A+DPTR        ; Load the first character in accumulator
	JZ    EXIT              ; Go to exit if zero
	ACALL LCD_SENDDATA      ; Send first char
	INC   DPTR              ; Increment data pointer
	SJMP  LCD_SENDSTRING    ; Jump back to send the next character
EXIT:    
	POP   0E0H

        RET                     ; End of routine

; Delay routine

DELAY:	 
	PUSH 0
	PUSH 1
	MOV R0, #1
LOOP2:	 
	MOV R1, #255
LOOP1:	 
	DJNZ R1,  LOOP1
	DJNZ R0,  LOOP2
	POP 1
	POP 0 

	RET

; ROM text strings

	ORG 300H
MY_STRING1:
        DB   "PT-51",  00H
MY_STRING2:
	DB   "IIT GOA",  00H
	
	ORG 200H
MAIN:
	MOV P2, #00H
	MOV P1, #00H
	    			; Initial delay for LCD power up
	  			; HERE1: SETB P1.0
        ACALL DELAY
				; CLR P1.0
  	ACALL DELAY
				; SJMP HERE1

	ACALL LCD_INIT      	; Initialise LCD
	
	ACALL DELAY
	ACALL DELAY
	ACALL DELAY
	MOV A, #85H		; Put cursor on first row, 5 column
	ACALL LCD_COMMAND	; Send command to LCD
	ACALL DELAY
	MOV   DPTR, #MY_STRING1 ; Load DPTR with SRING1 addr
	ACALL LCD_SENDSTRING    ; Call text strings sending routine
	ACALL DELAY
	
	MOV A, #0C3H		; Put cursor on second row, 3 column
	ACALL LCD_COMMAND
	ACALL DELAY
	MOV   DPTR, #MY_STRING2
	ACALL LCD_SENDSTRING
	
HERE: 
	SJMP HERE		; Perpetual loop
	
	END
