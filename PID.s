#include <xc.inc>
global Timer_Setup, PID_Cycle
    
global    scaled_err_x_H,scaled_err_x_L, scaled_err_y_H, scaled_err_y_L
 
extrn	UART_Setup, UART_Transmit_Message, UART_Write_Hex  ; external subroutines
extrn  LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Clear_Screen, LCD_New_Line
extrn  ADC_Init, ADC_Setup_X, ADC_Setup_Y, ADC_Read 
extrn Touchpanel_Coordinates_Hex,X_pos_H, X_pos_L, Y_pos_H, Y_pos_L
extrn Servo_Setup, S1_Pulse, S2_Pulse
extrn Numerical_Setup, Subtraction_16bit, S1_H, S1_L, S2_H, S2_L
extrn Division_by_Rotation_Signed_16_bit, D1_H, D1_L

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

PID_out_H:   ds 1
PID_out_L:   ds 1
    
scaled_err_x_H:	ds 1
scaled_err_x_L:   ds 1
scaled_err_y_H:	ds 1
scaled_err_y_L:   ds 1
    
scaled_der_x_H:   ds 1
scaled_der_x_L:   ds 1
scaled_der_y_H:   ds 1
scaled_der_y_L:   ds 1 

psect adc_code, class=CODE

    
Timer_Setup:
    clrf	TRISJ, A	; Set PORTD as all outputs
    clrf	LATJ, A		; Clear PORTD outputs
    movlw	10000111B	; Set timer1 to 16-bit, Fosc/4/25
    movwf	T0CON, A	; = 62.5KHz clock rate, approx 1sec rollover
    
    movlw   34
    movwf   servo_duty, A
    movlw   0x07
    movwf   centre_x_H, A
    movwf   centre_y_H, A
    movlw   0xB0
    movwf   centre_x_L,A
    movwf   centre_y_L,A
    
    
    
    
    bsf	TMR0IE		; Enable timer0 interrupt
    bsf	GIE		; Enable all interrupts
    return
    
PID_Cycle:
    
    movff   err_x_H, err_prev_x_H, A
    movff   err_x_L, err_prev_x_L, A
    movff   err_y_H, err_prev_y_H, A
    movff   err_y_L, err_prev_y_L, A
    
    movlw	0x10
    movwf	big_delay_count, A
    call	big_delay

    call	LCD_Clear_Screen
    
    btfss	TMR0IF		; check that this is timer1 interrupt
    retfie	f		; if not then return
    incf	LATJ, F, A	; increment PORTD

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
    
    movf err_x_H, W, A  
    call LCD_Write_Hex
    movf err_x_L, W, A  
    call LCD_Write_Hex
    
    movf err_y_H, W, A  
    call LCD_Write_Hex
    movf err_y_L, W, A  
    call LCD_Write_Hex
    
    movff   scaled_err_x_H, D1_H, A
    movff   scaled_err_x_L, D1_L, A
    
    call Division_by_Rotation_Signed_16_bit
    
    movff   D1_H, scaled_err_x_H, A
    movff   D1_L, scaled_err_x_L, A
    
    movff   scaled_err_y_H, D1_H, A
    movff   scaled_err_y_L, D1_L, A
    
    call Division_by_Rotation_Signed_16_bit
    
    movff   D1_H, scaled_err_y_H, A
    movff   D1_L, scaled_err_y_L, A
    
    movf scaled_err_x_H, W, A  
    call LCD_Write_Hex
    movf scaled_err_x_L, W, A  
    call LCD_Write_Hex
    
    movf scaled_err_y_H, W, A  
    call LCD_Write_Hex
    movf scaled_err_y_L, W, A  
    call LCD_Write_Hex
    
    
    
    // Calculate the derivative i.e. err - err_prev
    call LCD_New_Line
    movff  err_x_H, S1_H, A
    movff  err_x_L, S1_L, A
    movff  err_prev_x_H, S2_H, A
    movff  err_prev_x_L, S2_L, A
    
    call Subtraction_16bit
    
    movff S1_H, der_x_H, A
    movff S1_L, der_x_L, A

    movff der_x_H, scaled_der_x_H, A
    movff der_x_L,scaled_der_x_L, A
    
    movff  err_y_H, S1_H, A
    movff  err_y_L, S1_L, A
    movff  err_prev_y_H, S2_H, A
    movff  err_prev_y_L, S2_L, A
    
    call Subtraction_16bit
    
    movff S1_H, der_y_H, A
    movff S1_L, der_y_L, A
    
    movff der_y_H, scaled_der_y_H, A
    movff der_y_L,scaled_der_y_L, A
    
    
    movf der_x_H, W, A  
    call LCD_Write_Hex
    movf der_x_L, W, A  
    call LCD_Write_Hex
    
    movf der_y_H, W, A  
    call LCD_Write_Hex
    movf der_y_L, W, A  
    call LCD_Write_Hex
    
    movff   scaled_der_x_H, D1_H, A
    movff   scaled_der_x_L, D1_L, A
    
    call Division_by_Rotation_Signed_16_bit
    
    movff   D1_H, scaled_der_x_H, A
    movff   D1_L, scaled_der_x_L, A
    
    movff   scaled_der_y_H, D1_H, A
    movff   scaled_der_y_L, D1_L, A
    
    call Division_by_Rotation_Signed_16_bit
    
    movff   D1_H, scaled_der_y_H, A
    movff   D1_L, scaled_der_y_L, A
    
    movf scaled_der_x_H, W, A  
    call LCD_Write_Hex
    movf scaled_der_x_L, W, A  
    call LCD_Write_Hex
    
    movf scaled_der_y_H, W, A  
    call LCD_Write_Hex
    movf scaled_der_y_L, W, A  
    call LCD_Write_Hex
    
    
    ;58 - 90
    ;10 - -90
    ;34 - 0
    ;24 steps from 0 to 90
    ; 24 steps from 0 to -90

    movf    servo_duty, W, A
    call S2_Pulse
    //incf    servo_duty, 1, 0
    
    //incf    servo_counter, 1, 0
    //movlw    0x01
    //call UART_Write_Hex
    bcf	TMR0IF		; clear interrupt flag
    retfie	f		; fast return from interrupt
    

    
    
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
