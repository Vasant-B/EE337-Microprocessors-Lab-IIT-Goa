//-----------------------------------------------------------------------------
// LCD.c
//-----------------------------------------------------------------------------
// Last modified on 21-October-2018
//
// Program Description:
//
// Template file to display messages on LCD
//
// Target: AT89C5131A
// Tool chain: Keil C51
// Command Line: None
//
//-----------------------------------------------------------------------------
// Include necessary header files here
//-----------------------------------------------------------------------------

#include <AT89C5131.h> 							// All SFR declarations for AT89C5131

//-----------------------------------------------------------------------------
// Global Definitions
//-----------------------------------------------------------------------------

#define LCD_data  P2	    					// LCD Data port

//-----------------------------------------------------------------------------
// Function prototypes
//-----------------------------------------------------------------------------

void LCD_Init();
void LCD_DataWrite(char dat);
void LCD_CmdWrite(char cmd);
void LCD_WriteString(char * str, unsigned char len);
void LCD_Ready();
void sdelay(int delay);
void delay_ms(int delay);  

//-----------------------------------------------------------------------------
// Global Declarations
//-----------------------------------------------------------------------------

sbit CS_BAR = P1^4;								// Chip Select for the ADC
sbit LCD_rs = P0^0;  							// LCD Register Select
sbit LCD_rw = P0^1;  							// LCD Read/Write
sbit LCD_en = P0^2;  							// LCD Enable
sbit LCD_busy = P2^7;							// LCD Busy Flag 

//-----------------------------------------------------------------------------
// Global Variables
//-----------------------------------------------------------------------------

bit transmit_completed = 0;						// To check if SPI data transmit is complete
char serial_data, data_save_high, data_save_low;

//-----------------------------------------------------------------------------
// main() Routine
//-----------------------------------------------------------------------------

void main(void)
{				
	P2 = 0x00;									// Make Port 2 output 
	LCD_Init();
	while(1)			   						// Perpetual loop  
	{
		/* Code for displaying "Hello World"
			 on the LCD to be written here */
	}				
} 

//-----------------------------------------------------------------------------
// Function definitions
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// void LCD_Init()
//-----------------------------------------------------------------------------
//
// Purpose: LCD initialization
// Input Variables: None
// Return Value : None

void LCD_Init()
{	 
  	sdelay(100);
  	LCD_CmdWrite(0x38);   						// LCD 2lines, 5*7 matrix
  	LCD_CmdWrite(0x0E);							// Display ON cursor ON  Blinking off
  	LCD_CmdWrite(0x01);							// Clear the LCD
  	LCD_CmdWrite(0x80);							// Cursor to First line First Position
}	 

//-----------------------------------------------------------------------------
// void LCD_CmdWrite(char cmd)
//-----------------------------------------------------------------------------
//
// Purpose: Write commands to LCD
// Input Variables: cmd - command to be written
// Return Value : None

void LCD_CmdWrite(char cmd)
{																					  
	LCD_Ready();
	LCD_data = cmd;     						// Send the command to LCD
	LCD_rs = 0;         	 					// Select the Command Register by pulling LCD_rs LOW
 	LCD_rw = 0;          						// Select the Write Operation  by pulling RW LOW
  	LCD_en = 1;          						// Send a High-to-Low Pusle at Enable Pin
  	sdelay(5);
  	LCD_en = 0;
	sdelay(5);																		  
}  	 

//-----------------------------------------------------------------------------
// void LCD_DataWrite( char dat)
//-----------------------------------------------------------------------------
//
// Purpose: Write data to LCD
// Input Variables: dat - command to be written
// Return Value : None

void LCD_DataWrite( char dat)
{																					  
	LCD_Ready();
  	LCD_data = dat;	   							// Send the data to LCD
  	LCD_rs = 1;	   								// Select the Data Register by pulling LCD_rs HIGH
  	LCD_rw = 0;    	     						// Select the Write Operation by pulling RW LOW
  	LCD_en = 1;			   						// Send a High-to-Low Pusle at Enable Pin
  	sdelay(5);
  	LCD_en=0;
	sdelay(5);																		  
}	  	 

//-----------------------------------------------------------------------------
// void LCD_WriteString( char * str, unsigned char length)
//-----------------------------------------------------------------------------
//
// Purpose: Write a string on the LCD Screen
// Input Variables: str - pointer to the string to be written, length - length of the array
// Return Value : None

void LCD_WriteString( char * str, unsigned char length)
{																					  
    while(length>0)
    {																				  
        LCD_DataWrite(*str);
        str++;
        length--;																					  
    }			 
} 	  	 

//-----------------------------------------------------------------------------
// void LCD_Ready()
//-----------------------------------------------------------------------------
//
// Purpose: To check if the LCD is ready to communicate
// Input Variables: None
// Return Value : None

void LCD_Ready()
{				 
	LCD_data = 0xFF;
	LCD_rs = 0;
	LCD_rw = 1;
	LCD_en = 0;
	sdelay(5);
	LCD_en = 1;
	while(LCD_busy == 1)
	{			 
		LCD_en = 0;
		LCD_en = 1;
	}			   
	LCD_en = 0;	   
}  	  	 

//-----------------------------------------------------------------------------
// void sdelay(int delay)
//-----------------------------------------------------------------------------
//
// Purpose: A delay of multiples of 15us for a 24 MHz crystal
// Input Variables: delay - multiplication factor
// Return Value : None

void sdelay(int delay)
{
	char d=0;
	while(delay>0)
	{
		for(d=0;d<5;d++);
		delay--;
	}
} 	  	 

//-----------------------------------------------------------------------------
// void delay_ms(int delay)
//-----------------------------------------------------------------------------
//
// Purpose: A delay of around 1000us for a 24MHz crystal
// Input Variables: delay - multiplication factor
// Return Value : None

void delay_ms(int delay)
{
	int d=0;
	while(delay>0)
	{
		for(d=0;d<382;d++);
		delay--;
	}
} 

//-----------------------------------------------------------------------------
// End Of File
//-----------------------------------------------------------------------------