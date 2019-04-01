; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

ORG 0000H
ljmp start

org 200h
start:
      mov P2,#00h
	  mov P1,#00h
	  ;initial delay for lcd power up

;here1:setb p1.0
      acall delay
;	  clr p1.0
	  acall delay
;	  sjmp here1


	  acall lcd_init      ;initialise LCD
	
	  acall delay
	  acall delay
	  acall delay
	  mov a,#80h		 ;Put cursor on first row,0th column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov   dptr,#300h   ;Load DPTR with sring1 Addr
	  acall lcd_sendstring	   ;call text strings sending routine
	  acall delay
	  
	  acall delay
	  acall delay
	  acall delay
	  mov a,#0C0h		 ;Put cursor on 2nd row,0 column
	  acall lcd_command	 ;send command to LCD
	  acall delay

;	  mov   dptr,#my_string2   ;Load DPTR with sring1 Addr
;	  acall lcd_sendstring	   ;call text strings sending routine
;	  acall delay

		;Store V at 80H, A at 81H, S at 82H,...		
		MOV R0, #90H
		MOV @R0, #0FEH	;1-SPACE
		INC R0
		MOV @R0, #0FEH	;2-SPACE
		INC R0
		MOV @R0, #0FEH	;3-SPACE
		INC R0
		MOV @R0, #0FEH	;4-SPACE
		INC R0
		MOV @R0, #0FEH	;5-SPACE
		INC R0
		MOV @R0, #56H	;7-V
		INC R0
		MOV @R0, #41H	;8-A
		INC R0
		MOV @R0, #53H	;9-S
		INC R0
		MOV @R0, #41H	;10-A
		INC R0
		MOV @R0, #4EH	;11-N
		INC R0
		MOV @R0, #54H	;12-T
		INC R0
		MOV @R0, #0FEH	;13-SPACE
		INC R0
		MOV @R0, #0FEH	;14-SPACE
		INC R0
		MOV @R0, #0FEH	;15-SPACE
		INC R0
		MOV @R0, #0FEH	;16-SPACE
		INC R0
		MOV @R0, #0FEH	;17-SPACE
		INC R0
		MOV A, #90H
		MOV B, #16
		ACALL LCD_SEND_ASCII_NAME
		ACALL DELAY
		
	  
	  acall delay
	  acall delay
	  acall delay
	  
exit1:
         

	  acall delay

	  
here: sjmp here				//stay here 

;------------------------LCD Initialisation routine----------------------------------------------------
lcd_init:
         mov   LCD_data,#38H  ;Function set: 2 Line, 8-bit, 5x7 dots
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
	     acall delay

         mov   LCD_data,#0CH  ;Display on, Curson off
         clr   LCD_rs         ;Selected instruction register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay
         mov   LCD_data,#01H  ;Clear LCD
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay

         mov   LCD_data,#06H  ;Entry mode, auto increment with no shift
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en

		 acall delay
         
         ret                  ;Return from routine

;-----------------------command sending routine-------------------------------------
 lcd_command:
         mov   LCD_data,A     ;Move the command to LCD port
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
		 acall delay
    
         ret  
;-----------------------data sending routine-------------------------------------		     
 lcd_senddata:
         mov   LCD_data,A     ;Move the command to LCD port
         setb  LCD_rs         ;Selected data register
         clr   LCD_rw         ;We are writing
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         acall delay
		 acall delay
         ret                  ;Return from busy routine

;-----------------------text strings sending routine-------------------------------------
lcd_sendstring:
         clr   a                 ;clear Accumulator for any previous data
         movc  a,@a+dptr         ;load the first character in accumulator
         jz    exit              ;go to exit if zero
         acall lcd_senddata      ;send first char
         inc   dptr              ;increment data pointer
         sjmp  LCD_sendstring    ;jump back to send the next character
exit:
         ret                     ;End of routine

;-----------------------Displays B ASCII Values starting from A---------------------------
LCD_SEND_ASCII_NAME:
		USING 0
		PUSH AR1
		MOV R1, A
		LCD_SEND_ASCII_NAME_LOOP1:
		 mov   LCD_data, @R1  ;Move the command to LCD port
         setb  LCD_rs         ;Selected data register
         clr   LCD_rw         ;We are writing
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         acall delay
		 acall delay

		 INC R1
		 DJNZ B, LCD_SEND_ASCII_NAME_LOOP1
		 POP AR1
         ret                  ;Return from busy routine

;----------------------delay routine-----------------------------------------------------
delay:	 
         mov r2,#1
loop2:	 mov r3,#255
loop1:	 djnz r3, loop1
		 djnz r2,loop2
		 ret

;------------- ROM text strings---------------------------------------------------------------
org 300h
my_string1:
         DB   "EE 337 - IIT GOA", 00H
my_string2: 
		DB "IIT Goa" , 00H
end

