#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn  LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Clear_Screen, UART_Write_Hex
extrn  ADC_Init, ADC_Setup_X, ADC_Setup_Y, ADC_Read 
extrn Touchpanel_Coordinates_Hex
extrn Servo_Setup
    extrn Numerical_Setup
    
extrn	Timer_Setup
extrn	PID_Cycle
    

    
psect	code, abs	
rst: 	org 0x0000
 	goto	setup
	
int_hi: org 0x0008
    goto PID_Cycle

	; ******* Programme FLASH read Setup Code ***********************
setup:	
	call	UART_Setup	; setup UART
	call	LCD_Setup
	call	ADC_Init
	call	Servo_Setup
	call	Numerical_Setup
	
	goto	start



    
	; ******* Main programme ****************************************
start:
	call	Timer_Setup
loop: 
	goto	$	

	; a delay subroutine if you need one, times around loop in delay_count
