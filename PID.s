#include <xc.inc>
global Timer_Setup, TILT_Cycle
    
global    scaled_err_x_H,scaled_err_x_L, scaled_err_y_H, scaled_err_y_L, S1_pulse_value, S2_pulse_value
 
extrn	UART_Setup, UART_Transmit_Message, UART_Write_Hex  ; external subroutines
extrn  LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Clear_Screen, LCD_New_Line
extrn  ADC_Init, ADC_Setup_X, ADC_Setup_Y, ADC_Read 
extrn Touchpanel_Coordinates_Hex,X_pos_H, X_pos_L, Y_pos_H, Y_pos_L
extrn Servo_Setup, S_Pulse,S1_Pulse,S2_Pulse
extrn Numerical_Setup, Subtraction_16bit, S1_H, S1_L, S2_H, S2_L
extrn Division_by_Rotation_Signed_16_bit, D1_H, D1_L
extrn Scaling,    Dividend_H,    Dividend_L,    Divisor_H, Divisor_L,Scaling_by_Division_16bit_to_8bit
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
    
err_prev_x_H:	ds 1
err_prev_x_L:	ds 1
err_prev_y_H:	ds 1
err_prev_y_L:	ds 1
    
der_x_H:	ds 1
der_x_L:	ds 1
der_y_H:	ds 1
der_y_L:	ds 1

TILT_out_x_H:   ds 1
TILT_out_x_L:   ds 1
    
TILT_out_y_H:   ds 1
TILT_out_y_L:   ds 1

Control_out_x_H:   ds 1
Control_out_x_L:   ds 1
    
Control_out_y_H:   ds 1
Control_out_y_L:   ds 1
    
scaled_err_x_H:	ds 1
scaled_err_x_L:   ds 1
scaled_err_y_H:	ds 1
scaled_err_y_L:   ds 1
    
scaled_der_x_H:   ds 1
scaled_der_x_L:   ds 1
scaled_der_y_H:   ds 1
scaled_der_y_L:   ds 1
    
Threshold_H: ds 1
Threshold_L: ds 1
    
S1_pulse_value: ds 1
    
S2_pulse_value: ds 1

psect adc_code, class=CODE

    
Timer_Setup:
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
    bsf LATJ, 0, A
    movff   err_x_H, err_prev_x_H, A
    movff   err_x_L, err_prev_x_L, A
    movff   err_y_H, err_prev_y_H, A
    movff   err_y_L, err_prev_y_L, A
    
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
    
    movff err_x_H, scaled_err_x_H, A
    movff err_x_L, scaled_err_x_L, A
    
    
    
    movff  Y_pos_H, S1_H, A
    movff  Y_pos_L, S1_L, A
    movff  centre_y_H, S2_H, A
    movff  centre_y_L, S2_L, A
    
    call Subtraction_16bit
    
    movff S1_H, err_y_H, A
    movff S1_L, err_y_L, A
    
    movff err_y_H, scaled_err_y_H, A
    movff err_y_L, scaled_err_y_L, A
    

    movff scaled_err_x_L, TILT_out_x_L
    movff scaled_err_x_H, TILT_out_x_H
    
    movff scaled_err_y_L, TILT_out_y_L
    movff scaled_err_y_H, TILT_out_y_H
    

    
    call LCD_New_Line
    

    // Calculates the absolute value of the TILT output
    
    btfss TILT_out_x_H, 7, 0
    goto skip_TILT_x_2s_un_complement
    
	movff TILT_out_x_L, S1_L, A
	movff TILT_out_x_H, S1_H, A
	movlw 0
	movwf S2_H, A
	movlw 1
	movwf S2_L, A

	call Subtraction_16bit

	comf S1_H, 0, 0
	movwf   Control_out_x_H, A
	comf S1_L, 0, 0
	movwf   Control_out_x_L, A
    
    skip_TILT_x_2s_un_complement:
    btfsc TILT_out_x_H, 7, 0
    goto control_x_already_set
    
	movff TILT_out_x_H,  Control_out_x_H, A
	movff TILT_out_x_L,  Control_out_x_L, A
    
    control_x_already_set:

    
    
    btfss TILT_out_y_H, 7, 0
    goto skip_TILT_y_2s_un_complement
    
	movff TILT_out_y_L, S1_L, A
	movff TILT_out_y_H, S1_H, A
	movlw 0
	movwf S2_H, A
	movlw 1
	movwf S2_L, A

	call Subtraction_16bit

	comf S1_H, 0, 0
	movwf   Control_out_y_H, A
	comf S1_L, 0, 0
	movwf   Control_out_y_L, A
    
    skip_TILT_y_2s_un_complement:
    btfsc TILT_out_y_H, 7, 0
    goto control_y_already_set
    
	movff TILT_out_y_H,  Control_out_y_H, A
	movff TILT_out_y_L,  Control_out_y_L, A
    
    control_y_already_set:
    bcf LATJ, 0, A
    //movf Control_out_x_H, W, A 
    //call LCD_Write_Hex
    //movf Control_out_x_L, W, A
    //call LCD_Write_Hex
    
    //movf Control_out_y_H, W, A  
    //call LCD_Write_Hex
    //movf Control_out_y_L, W, A  
    //call LCD_Write_Hex
    
    // convert from FFFFh to range 24d
    // Divide TILT value by a threshold value and multiply by 24
    
    movff Control_out_x_H, Dividend_H, A
    movff Control_out_x_L, Dividend_L, A
    movff Threshold_H, Divisor_H, A
    movff Threshold_L, Divisor_L, A
    movlw 20
    movwf Scaling, A
    call Scaling_by_Division_16bit_to_8bit
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
    call Scaling_by_Division_16bit_to_8bit
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
    
    //call LCD_Write_Hex
    ;58 - 90
    ;10 - -90
    ;34 - 0
    ;24 steps from 0 to 90
    ; 24 steps from 0 to -90

    //movf    servo_duty, W, A
    //incf    servo_duty, 1, 0
    
    //incf    servo_counter, 1, 0
    //movlw    0x01
    //call UART_Write_Hex
    //bcf	TMR0IF		; clear interrupt flag
    //retfie	f		; fast return from interrupt
    
    
    
    call big_delay
    call big_delay
    call big_delay
    call big_delay
    call big_delay
    call big_delay
    call big_delay
    call big_delay
    call big_delay
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
