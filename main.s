#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn  LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Clear_Screen
extrn  ADC_Init, ADC_Setup_X, ADC_Setup_Y, ADC_Read 
extrn Touchpanel_Coordinates_Hex
extrn Servo_Setup, Servo_Pulse
    
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
big_delay_count: ds 1
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup
	call	ADC_Init
	call	Servo_Setup
	goto	start
	
	; ******* Main programme ****************************************
start:

loop: 
	;call Touchpanel_Coordinates_Hex
	movlw	
	
	call Servo_Pulse
	movlw	0x60
	movwf	big_delay_count, A
	call	big_delay
	
	call	LCD_Clear_Screen
	
	
	goto	loop	

	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return
big_delay: 
    
	movlw	0xff
	movwf	delay_count, A
	call	delay
	decfsz	big_delay_count, A
	bra big_delay
	
	return

	end	rst