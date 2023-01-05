#include <xc.inc>
global TILT_Setup, TILT_Cycle
    
global    S1_pulse_value, S2_pulse_value
 
extrn	UART_Setup, UART_Transmit_Message, UART_Write_Hex  ; external subroutines
extrn  LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Clear_Screen, LCD_New_Line
extrn  ADC_Init, ADC_Setup_X, ADC_Setup_Y, ADC_Read 
extrn Touchpanel_Coordinates_Hex,X_pos_H, X_pos_L, Y_pos_H, Y_pos_L
extrn Servo_Setup, S_Pulse,S1_Pulse,S2_Pulse
extrn Subtraction_16bit, S1_H, S1_L, S2_H, S2_L
extrn Scaling,    Dividend_H,    Dividend_L,    Divisor_H, Divisor_L, Scaling_by_Division_16bit_to_8bit
extrn ABS_H, ABS_L,Absolute_Value_2scomp
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
big_delay_count: ds 1
    
servo_duty:	ds 1
centre_x_H:	ds 1
centre_x_L:	ds 1
centre_y_H:	ds 1
centre_y_L:	ds 1
    
    
err_x_H:	ds 1
err_x_L:	ds 1
err_y_H:	ds 1
err_y_L:	ds 1

TILT_out_x_H:   ds 1
TILT_out_x_L:   ds 1
    
TILT_out_y_H:   ds 1
TILT_out_y_L:   ds 1

Control_out_x_H:   ds 1
Control_out_x_L:   ds 1
    
Control_out_y_H:   ds 1
Control_out_y_L:   ds 1
    
Threshold_H: ds 1
Threshold_L: ds 1
    
S1_pulse_value: ds 1
    
S2_pulse_value: ds 1

psect adc_code, class=CODE

    
TILT_Setup:
    clrf	TRISJ, A	; Set PORTD as all outputs
    clrf	LATJ, A		; Clear PORTD outputs
    //movlw	10000001B	; Set timer1 to 16-bit, Fosc/4/25
    //movwf	T0CON, A	; = 62.5KHz clock rate, approx 1sec rollover
    
    movlw   34
    movwf   servo_duty, A
    movlw   34
    call S1_Pulse
    movlw   34
    call S2_Pulse
    movlw   0x08
    movwf   centre_x_H, A
    movwf   centre_y_H, A
    movlw   0xB0
    movwf   centre_x_L,A
    movwf   centre_y_L,A
    
    movlw 0x06
    movwf   Threshold_H, A
    movlw 0x00
    movwf   Threshold_L, A
    
    
    //bsf	TMR0IE		; Enable timer0 interrupt
    //bsf	GIE		; Enable all interrupts
    return
    
TILT_Cycle:
    bsf LATJ, 0, A // for debugging: checking clock cycle of the program
    
   // movlw	0x10
    //movwf	big_delay_count, A
   // call	big_delay

   // call	LCD_Clear_Screen
    
    //btfss	TMR0IF		; check that this is timer1 interrupt
    //retfie	f		; if not then return
    

    call Touchpanel_Coordinates_Hex
    
    // Calculating Error
    
    movff  X_pos_H, S1_H, A
    movff  X_pos_L, S1_L, A
    movff  centre_x_H, S2_H, A
    movff  centre_x_L, S2_L, A
    
    call Subtraction_16bit
    
    movff S1_H, err_x_H, A
    movff S1_L, err_x_L, A
    
    movff err_x_H, TILT_out_x_H, A
    movff err_x_L, TILT_out_x_L, A
    
    
    
    movff  Y_pos_H, S1_H, A
    movff  Y_pos_L, S1_L, A
    movff  centre_y_H, S2_H, A
    movff  centre_y_L, S2_L, A
    
    call Subtraction_16bit
    
    movff S1_H, err_y_H, A
    movff S1_L, err_y_L, A
    
    movff err_y_H, TILT_out_y_H, A
    movff err_y_L, TILT_out_y_L, A
   
    

    // Calculates the absolute value of the TILT output
    
    movff TILT_out_x_H, ABS_H, A
    movff TILT_out_x_L, ABS_L, A
    
    call Absolute_Value_2scomp
    
    movff ABS_H,  Control_out_x_H, A
    movff ABS_L,  Control_out_x_L, A
    
    
    
    movff TILT_out_y_H, ABS_H, A
    movff TILT_out_y_L, ABS_L, A
    
    call Absolute_Value_2scomp
    
    movff ABS_H,  Control_out_y_H, A
    movff ABS_L,  Control_out_y_L, A
    
    
    // convert from Threshold to range 24d
    // Divide TILT value by a threshold value and multiply by 24
    
    movff Control_out_x_H, Dividend_H, A
    movff Control_out_x_L, Dividend_L, A
    movff Threshold_H, Divisor_H, A
    movff Threshold_L, Divisor_L, A
    movlw 20
    movwf Scaling, A
    call Scaling_by_Division_16bit_to_8bit // INTEGER DEVISION IS STORED IN PRODH
    
    btfss TILT_out_x_H, 7, 0
    goto servo_boost_negative_x
    servo_boost_positive_x:
    movf servo_duty, W, A
    addwf PRODH, W, A
    goto servo_boost_end_x
    servo_boost_negative_x:
    movf PRODH, W, A   
    subwf servo_duty, W, A
    servo_boost_end_x:

    movwf S2_pulse_value, A

    
    
    movff Control_out_y_H, Dividend_H, A
    movff Control_out_y_L, Dividend_L, A
    movff Threshold_H, Divisor_H, A
    movff Threshold_L, Divisor_L, A
    movlw 20
    movwf Scaling, A
    call Scaling_by_Division_16bit_to_8bit // INTEGER DEVISION IS STORED IN PRODH
    
    btfss TILT_out_y_H, 7, 0
    goto servo_boost_negative_y
    servo_boost_positive_y:
    movf servo_duty, W, A
    addwf PRODH, W, A
    goto servo_boost_end_y
    servo_boost_negative_y:
    movf PRODH, W, A   
    subwf servo_duty, W, A
    servo_boost_end_y:
    movwf S1_pulse_value, A
    
    
    call S_Pulse

    ;58 - 90
    ;10 - -90
    ;34 - 0
    ;24 steps from 0 to 90
    ; 24 steps from 0 to -90
    bcf LATJ, 0, A
   
return

    
    
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
