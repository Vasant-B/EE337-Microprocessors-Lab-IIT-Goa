//-----------------------------------------------------------------------------
// ADC.c
//-----------------------------------------------------------------------------
// Last modified on 21-October-2018
//
// Program Description:
//
// Template file for ADC interfacing
//
// Target: AT89C5131A
// Tool chain: Keil C51
// Command Line: None
//
//-----------------------------------------------------------------------------
// Include necessary header files here
//-----------------------------------------------------------------------------

#include <AT89C5131.h> 							// All SFR declarations for AT89C5131
#include <stdio.h>		 

//-----------------------------------------------------------------------------
// Global Definitions
//-----------------------------------------------------------------------------

#define LCD_data  P2	    					// LCD Data port  

//-----------------------------------------------------------------------------
// Function prototypes
//-----------------------------------------------------------------------------

void SPI_Init();
void LCD_Init();
void Timer_Init();
void LCD_DataWrite(char dat);
void LCD_CmdWrite(char cmd);
void LCD_StringWrite(char * str, unsigned char len);
void LCD_Ready();
void sdelay(int delay);
void delay_ms(int delay);
char int_to_string(int val);  

//-----------------------------------------------------------------------------
// Global Declarations
//-----------------------------------------------------------------------------

sbit CS_BAR = P1^4;								// Chip Select for the ADC
sbit LCD_rs = P0^0;  							// LCD Register Select
sbit LCD_rw = P0^1;  							// LCD Read/Write
sbit LCD_en = P0^2;  							// LCD Enable
sbit LCD_busy = P2^7;							// LCD Busy Flag
sbit ONULL = P1^0;
bit transmit_completed= 0;						// To check if spi data transmit is complete
bit offset_null = 0;							// Check if offset nulling is enabled
bit roundoff = 0;
int adcVal=0, avgVal=0, initVal=0, adcValue = 0;
unsigned char serial_data;
unsigned char data_save_high;
unsigned char data_save_low;
unsigned char count=0, i=0;
unsigned char weight[4];
unsigned char voltage[4];
float fweight=0;  

//-----------------------------------------------------------------------------
// main() Routine
//-----------------------------------------------------------------------------
//
// Input Variables:  P1.5(MISO) serial input  
// Output Variables: P1.7(MOSI) serial output
//                   P1.4(SSbar)
//                   P1.6(SCK)

void main(void)
{
	P3 = 0X00;									// Make Port 3 output 
	P2 = 0x00;									// Make Port 2 output 
	P1 &= 0xEF;									// Make P1 Pin4-7 output
	P0 &= 0xF0;									// Make Port 0 Pins 0,1,2 output
	
	SPI_Init();
	LCD_Init();
	Timer_Init();
	
	while(1)									// Perpetual loop 
	{
		CS_BAR = 0;                 			// enable ADC as slave		 
		SPDAT= 0x01;							// Write start bit to start ADC 
		while(!transmit_completed);				// wait end of transmition;TILL SPIF = 1 i.e. MSB of SPSTA
		transmit_completed = 0;    				// clear software transfert flag 
		
		SPDAT= 0x80;							// 80H written to start ADC CH0 single ended sampling, refer ADC datasheet
		while(!transmit_completed);				// wait end of transmition 
		data_save_high = serial_data & 0x03 ;  
		transmit_completed = 0;    				// clear software transfer flag 
				
		SPDAT= 0x00;							 
		while(!transmit_completed);				// wait end of transmition 
		data_save_low = serial_data;
		transmit_completed = 0;    				// clear software transfer flag 
		CS_BAR = 1;                				// disable ADC as slave
		
		adcVal = (data_save_high <<8) + (data_save_low);  		
	}
}   

//-----------------------------------------------------------------------------
// Function definitions
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// void it_SPI(void) interrupt 9
//-----------------------------------------------------------------------------
//
// Purpose: Interrupt service
// Input Variables: None
// Return Value : transmit_complete is software transfert flag

void it_SPI(void) interrupt 9 					// Interrupt address is 0x004B, (Address-3)/8 = interrupt no.
{
	switch(SPSTA)         						// Read and clear spi status register
	{
		case 0x80:	
			serial_data=SPDAT;   				// Read receive data
      		transmit_completed=1;				// set software flag
 		break;

		case 0x10:
         										// Code here for mode fault tasking
		break;
	
		case 0x40:
         										// Code here for overrun tasking
		break;
	}
}	

//-----------------------------------------------------------------------------
// void timer0_ISR (void) interrupt 1
//-----------------------------------------------------------------------------
//
// Purpose: Interrupt service routine for timer
// Input Variables: None
// Return Value : None

void timer0_ISR (void) interrupt 1
{
												// Initialize TH0
												// Initialize TL0
												// Increment Overflow 
												// Write averaging of 10 samples code here	 
}	

//-----------------------------------------------------------------------------
// void SPI_Init()
//-----------------------------------------------------------------------------
//
// Purpose: SPI initialization
// Input Variables: None
// Return Value : None

void SPI_Init()
{
	CS_BAR = 1;	                  				// Disable ADC slave select - CS 
	SPCON |= 0x20;               	 			// P1.1(SSBAR) is available as standard I/O pin 
	SPCON |= 0x01;                				// Fclk Periph/4 AND Fclk Periph = 12MHz, hence SCK IE. BAUD RATE=3000kHz 
	SPCON |= 0x10;               	 			// Master mode 
	SPCON &= ~0x08;               				// CPOL=0; transmit mode example|| SCK is 0 at idle state
	SPCON |= 0x04;                				// CPHA=1; transmit mode example 
	IEN1 |= 0x04;                	 			// Enable spi interrupt 
	EA=1;                         				// Enable interrupts 
	SPCON |= 0x40;                				// Run spi; Enable SPI Interface SPEN= 1 
}	

//-----------------------------------------------------------------------------
// void Timer_Init()
//-----------------------------------------------------------------------------
//
// Purpose: Timer initialization
// Input Variables: None
// Return Value : None

void Timer_Init()
{
												// Set Timer0 to work in up counting 16 bit mode. Counts upto 
												// 65536 depending upon the calues of TH0 and TL0
												// The timer counts 65536 processor cycles. A processor cycle is 
												// 12 clocks. FOr 24 MHz, it takes 65536/2 uS to overflow											    
												// Initialize TH0
												// Initialize TL0
												// Configure TMOD 
												// Set ET0
												// Set TR0
}

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