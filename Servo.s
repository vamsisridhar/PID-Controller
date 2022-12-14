#include <xc.inc>

global Servo_Setup,S1_Pulse, S2_Pulse
    
psect udata_acs, space = 1
    S1_PWM EQU 0
    S2_PWM EQU 1
    Servo_cnt_l:	ds 1	; reserve 1 byte for variable LCD_cnt_l
    Servo_cnt_h:	ds 1	; reserve 1 byte for variable LCD_cnt_h
    Servo_cnt_ms:	ds 1	; reserve 1 byte for ms counter
    Servo_duty_delay:   ds 1
    servo_counter:	ds 1
psect servo_code, class =CODE
    
    Servo_Setup:
	bcf TRISD, S1_PWM, A
	bcf TRISD, S2_PWM, A
	return
	
	
    S1_Pulse:
    
    	movwf   Servo_duty_delay, A
        movlw   20
	movwf    servo_counter, A
	servo_pulsing1:
	    movf   Servo_duty_delay, W, A
	    bsf LATD, S1_PWM, A
	    call Servo_delay_ms
	    bcf LATD, S1_PWM, A
	    movf	Servo_duty_delay, W, A
	    sublw	250
	    call Servo_delay_ms
	    movlw	250
	    call Servo_delay_ms
	    decfsz	servo_counter, A
	    goto servo_pulsing1
	return

    S2_Pulse:
	movwf   Servo_duty_delay, A
        movlw   20
	movwf    servo_counter, A
	servo_pulsing2:
	    movf   Servo_duty_delay, W, A
	    bsf LATD, S2_PWM, A
	    call Servo_delay_ms
	    bcf LATD, S2_PWM, A
	    movf	Servo_duty_delay, W, A
	    sublw	250
	    call Servo_delay_ms
	    movlw	250
	    call Servo_delay_ms
	    decfsz	servo_counter, A
	    goto servo_pulsing2

	
	return	
	
	; 250 is 1 ms
    Servo_delay_ms:		    ; delay given in ms in W
	movwf	Servo_cnt_ms, A
	ser_dl2:movlw	10	
		call	Servo_delay_x4us	
		decfsz	Servo_cnt_ms, A
		bra	ser_dl2
		return

    Servo_delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	Servo_cnt_l, A	; now need to multiply by 16
	swapf   Servo_cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	Servo_cnt_l, W, A ; move low nibble to W
	movwf	Servo_cnt_h, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	Servo_cnt_l, F, A ; keep high nibble in LCD_cnt_l
	call	Servo_delay
	return

    Servo_delay:			; delay routine	4 instruction loop == 250ns	    
	    movlw 	0x00		; W=0
    ser_dl1:	decf 	Servo_cnt_l, F, A	; no carry when 0x00 -> 0xff
	    subwfb 	Servo_cnt_h, F, A	; no carry when 0x00 -> 0xff
	    bc 	ser_dl1		; carry, then loop again
	    return	
    
end


