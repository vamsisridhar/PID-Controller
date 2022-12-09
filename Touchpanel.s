#include <xc.inc>

global Touchpanel_Coordinates_Hex
extrn  ADC_Setup_X, ADC_Setup_Y, ADC_Read
extrn	LCD_Write_Hex, UART_Transmit_Message, UART_Write_Hex
extrn IIR_Filter_X, IIR_Filter_Y

    
psect	udata_acs
	Touchpanel_cnt_l:	ds 1	; reserve 1 byte for variable LCD_cnt_l
        Touchpanel_cnt_h:	ds 1	; reserve 1 byte for variable LCD_cnt_h
	Touchpanel_cnt_2:	ds 1
	Touchpanel_cnt_ms:	ds 1	; reserve 1 byte for ms counter
psect	touchpanel_code, class=CODE

Touchpanel_delay_1us:
	decfsz	Touchpanel_cnt_2, A
	bra	Touchpanel_delay_1us
	movlw	0x0F
	movwf	Touchpanel_cnt_2, A
	return
   
Touchpanel_delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	Touchpanel_cnt_l, A	    ; now need to multiply by 16
	swapf   Touchpanel_cnt_l, F, A    ; swap nibbles
	movlw	0x0f	    
	andwf	Touchpanel_cnt_l, W, A    ; move low nibble to W
	movwf	Touchpanel_cnt_h, A	    ; then to Touchpanel_cnt_h
	movlw	0xf0	    
	andwf	Touchpanel_cnt_l, F, A    ; keep high nibble in Touchpanel_cnt_l
	call	Touchpanel_delay
	return

Touchpanel_delay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
glcdlp1:	
	decf 	Touchpanel_cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	Touchpanel_cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	glcdlp1		; carry, then loop again
	return			; carry reset so return	

Touchpanel_delay_ms:		    ; delay given in ms in W
	movwf	Touchpanel_cnt_ms, A
glcdlp2:	
	movlw	125	    ; 1 ms delay
	call	Touchpanel_delay_x4us	
	decfsz	Touchpanel_cnt_ms, A
	bra	glcdlp2
	return
    	
Touchpanel_Coordinates_Hex:
    call ADC_Setup_Y
    movlw   1
    call Touchpanel_delay_ms
    call ADC_Read
    
    //call Moving_Average
   
    swapf ADRESH, 1, 0
    movlw   0xF0
    andwf ADRESH, 1, 0
    
    swapf ADRESL, 0, 0
    movlw   0x0F
    andwf ADRESL, 0, 0
    
    addwf ADRESH, 0, 0
    //call IIR_Filter_Y
    //call LCD_Write_Hex
    call UART_Write_Hex
    
    call ADC_Setup_X
    movlw   1
    call Touchpanel_delay_ms
    call ADC_Read
    //call Moving_Average
    
    swapf ADRESH, 1, 0
    movlw   0xF0
    andwf ADRESH, 1, 0
    
    swapf ADRESL, 0, 0
    movlw   0x0F
    andwf ADRESL, 0, 0
    
    addwf ADRESH, 0, 0
    //call IIR_Filter_X
    //call LCD_Write_Hex
    call UART_Write_Hex
    
    return
    
    
end