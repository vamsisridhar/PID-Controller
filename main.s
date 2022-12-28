#include <xc.inc>

extrn	UART_Setup, UART_Write_Hex  ; external subroutines
extrn  ADC_Init
extrn Touchpanel_Coordinates_Hex
extrn Servo_Setup
extrn Servo_Setup,S1_Pulse, S2_Pulse
    
extrn	TILT_Setup
extrn	TILT_Cycle
psect udata_acs
 counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
big_delay_count: ds 1
    
psect	code, abs	
rst: 	org 0x0000
 	goto	setup
	
int_hi: org 0x0008
    goto TILT_Cycle

	; ******* Programme FLASH read Setup Code ***********************
setup:	
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	call	ADC_Init	; setup Analogn to Digital Converter
	call	Servo_Setup	; setup Servo
	
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
	call	TILT_Setup
	
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