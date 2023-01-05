#include <xc.inc>

global Servo_Setup,S1_Pulse, S2_Pulse, S_Pulse
extrn S1_pulse_value, S2_pulse_value
psect udata_acs, space = 1
    S1_PWM EQU 0
    S2_PWM EQU 1
    Servo_cnt_l:	ds 1	; reserve 1 byte for variable Servo_cnt_l
    Servo_cnt_h:	ds 1	; reserve 1 byte for variable Servo_cnt_h
    Servo_cnt_ms:	ds 1	; reserve 1 byte for ms counter
    Servo_duty_delay:   ds 1	
    servo_counter:	ds 1
psect servo_code, class =CODE
    
    Servo_Setup:
	// sets outputs
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

    S_Pulse:
        movlw   20				; sends 20 pulses
	movwf    servo_counter, A
	servo_pulsing:
	    movf   S2_pulse_value, W, A         ; value of S2 pulse
	    bsf LATD, S2_PWM, A			; start pwm with high for Servo 2
	    call Servo_delay_ms			; wait for the specified duty cycle 
	    bcf LATD, S2_PWM, A			; end pwm pulse
	    movf	S2_pulse_value, W, A	; low for the rest of the 20ms pulse
	    sublw	250			
	    call Servo_delay_ms			; (10ms - servo high time) delay			
	    movlw	250 
	    call Servo_delay_ms			; 10ms delay
	    
	    
	    movf   S1_pulse_value, W, A		; same as above but for Servo 1
	    bsf LATD, S1_PWM, A
	    call Servo_delay_ms
	    bcf LATD, S1_PWM, A
	    movf	S1_pulse_value, W, A
	    sublw	250
	    call Servo_delay_ms
	    movlw	250
	    call Servo_delay_ms
	    
	    
	    decfsz	servo_counter, A	; repeat pulse 20 times so servo has continuous movement
	    goto servo_pulsing

	
	return	
	
	
    ; modified delay from LCD.s
    Servo_delay_ms:		    ; delay given in ms in W
	movwf	Servo_cnt_ms, A
	ser_dl2:movlw	10	    ; 1/25 ms delay
		call	Servo_delay_x4us	
		decfsz	Servo_cnt_ms, A
		bra	ser_dl2
		return

    Servo_delay_x4us:		   
	movwf	Servo_cnt_l, A	
	swapf   Servo_cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	Servo_cnt_l, W, A ; move low nibble to W
	movwf	Servo_cnt_h, A	; then to Servo_cnt_h
	movlw	0xf0	    
	andwf	Servo_cnt_l, F, A ; keep high nibble in Servo_cnt_l
	call	Servo_delay
	return

    Servo_delay:			    
	    movlw 	0x00		; W=0
    ser_dl1:	decf 	Servo_cnt_l, F, A	; no carry when 0x00 -> 0xff
	    subwfb 	Servo_cnt_h, F, A	; no carry when 0x00 -> 0xff
	    bc 	ser_dl1		; carry, then loop again
	    return	
    
end


