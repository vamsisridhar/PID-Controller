#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn  LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Clear_Screen, UART_Write_Hex
extrn  ADC_Init, ADC_Setup_X, ADC_Setup_Y, ADC_Read 
extrn Touchpanel_Coordinates_Hex
extrn Servo_Setup, Servo_Pulse
    extrn Numerical_Setup
    
extrn	Timer_Setup
extrn	PID_Cycle
    
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
big_delay_count: ds 1
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	call	UART_Setup	; setup UART
	call	LCD_Setup
	call	ADC_Init
	call	Servo_Setup
	call	Numerical_Setup
	
	goto	start


;int_hi: org 0x0008
;    goto PID_Cycle
    
	; ******* Main programme ****************************************
start:
	call	Timer_Setup
loop: 
	call Touchpanel_Coordinates_Hex
	//movlw	22
	
	//call Servo_Pulse
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