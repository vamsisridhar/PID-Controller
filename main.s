#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn  LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Clear_Screen, UART_Write_Hex
extrn  LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Clear_Screen, LCD_New_Line
extrn  ADC_Init, ADC_Setup_X, ADC_Setup_Y, ADC_Read 
extrn Touchpanel_Coordinates_Hex
extrn Servo_Setup
    extrn Servo_Setup,S1_Pulse, S2_Pulse
    extrn Numerical_Setup
    
extrn	Timer_Setup
extrn	TILT_Cycle
psect udata_acs
 counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
big_delay_count: ds 1
test_v1: ds 1
test_v2: ds 1
test_v3: ds 1
test_v4: ds 1
    
psect	code, abs	
rst: 	org 0x0000
 	goto	setup
	
int_hi: org 0x0008
    goto TILT_Cycle

	; ******* Programme FLASH read Setup Code ***********************
setup:	
	call	UART_Setup	; setup UART
	call	LCD_Setup
	call	ADC_Init
	call	Servo_Setup
	call	Numerical_Setup
	
	movlw 0xBB
	call UART_Write_Hex
	
	goto	start



test_start_loop:
    call Touchpanel_Coordinates_Hex
    movlw 34
    call S1_Pulse
    movlw 34
    call S2_Pulse
    
   movlw 0xAA
   call UART_Write_Hex
      movlw 0xAA
   call UART_Write_Hex
    
    
    
    goto test_start_loop
    
	; ******* Main programme ****************************************
start:
	call	Timer_Setup
	
loop: 
	call TILT_Cycle
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