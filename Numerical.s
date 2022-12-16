#include <xc.inc>
global Numerical_Setup, IIR_Filter_X,IIR_Filter_Y 
global IIR_Sum_X_L, IIR_Sum_X_H, IIR_Sum_Y_L, IIR_Sum_Y_H
global Subtraction_16bit, S1_H, S1_L, S2_H, S2_L,LCD_Write_Hex
global Division_by_Rotation_Signed_16_bit, D1_H, D1_L, Decimal, division_counter
global     Scaling,    Dividend_H,    Dividend_L,    Divisor_H, Divisor_L,Scaling_by_Division_16bit_to_8bit
psect udata_acs
 
    IIR_Sum_X_H:  ds 1
    IIR_Sum_X_L:  ds 1
    IIR_Input_X:  ds 1
    IIR_Sum_Y_H:  ds 1
    IIR_Sum_Y_L:  ds 1
    IIR_Input_Y:  ds 1
    
    S1_H: ds 1
    S1_L: ds 1
    S2_H: ds 1
    S2_L: ds 1
    
    D1_H: ds 1
    D1_L: ds 1
    
    negative_register: ds 1
    
    Decimal: ds 1
    Scaling: ds 1
    Dividend_H: ds 1
    Dividend_L: ds 1
    Divisor_H: ds 1
    Divisor_L: ds 1
    division_counter: ds 1
    // bit 0 is used to track negative when performing division
    
psect numerical_code, class =CODE
Numerical_Setup:
    movlw 0x00
    movwf  IIR_Sum_X_H, A
    movwf  IIR_Sum_Y_H, A
    movwf  IIR_Sum_X_L, A
    movwf  IIR_Sum_Y_L, A
    return

IIR_Filter_X:
    bcf	    CARRY
    rrcf    IIR_Sum_X_H, 1, 0
    rrcf    IIR_Sum_X_L, 1, 0
    
    movwf   IIR_Input_X, A
    ;rrcf    IIR_Input_X, 1, 0
    ;rrcf    IIR_Input_X, 1, 0
    ;rrcf    IIR_Input_X, 1, 0
    ;rrcf    IIR_Input_X, 0, 0
    
    addwf   IIR_Sum_X_L, 1, 0
    
    movlw 0x0
    addwfc   IIR_Sum_X_H, 1, 0
    
    
    bcf	    CARRY
    ;rlcf    IIR_Sum_X, 0, 1
    ;movf    IIR_Sum_X, W, A

    return
    
    
IIR_Filter_Y:


    bcf	    CARRY
    rrcf    IIR_Sum_Y_H, 1, 0
    rrcf    IIR_Sum_Y_L, 1, 0
    movwf   IIR_Input_Y, A
   ;rrcf    IIR_Input_Y, 1, 0
    ;rrcf    IIR_Input_Y, 1, 0
    ;rrcf    IIR_Input_Y, 1, 0
    ;rrcf    IIR_Input_Y, 0, 0
    addwf   IIR_Sum_Y_L, 1, 0
    movlw 0x0
    
    addwfc   IIR_Sum_Y_H, 1, 0
    
    
    bcf	    CARRY
    ;rlcf    IIR_Sum_Y, 0, 1
;movf    IIR_Sum_Y, W, A

return

Subtraction_16bit:
    bsf CARRY  // No borrow
    bcf ZERO   // not zero
    bcf	NEGATIVE // positive
    
    ; S1 - S2 -> S1
    
    movf S2_L, 0, 0
    subwf S1_L, 1, 0
    
    movf S2_H, 0, 0
    subwfb S1_H, 1, 0
   
    return
    
Division_by_Rotation_Signed_16_bit:
    bcf	negative_register, 0, 0
    btfss D1_H, 7, 0
    goto apply_scaling
    // skips to apply_scaling if positive
    //bcf D1_H, 7, 0
    bsf	negative_register, 0, 0
    
    apply_scaling:
    bcf	CARRY
    btfsc negative_register, 0, 0
    bsf	CARRY
    rrcf D1_H, 1, 0
    rrcf D1_L, 1, 0
    
    //bcf CARRY
    //btfsc negative_register, 0, 0
    //bsf	CARRY
    //rrcf D1_H, 1, 0
    //rrcf D1_L, 1, 0

    bcf	negative_register, 0, 0
    return

    
Scaling_by_Division_16bit_to_8bit:

    movlw 0x00
    movwf Decimal, A
    movlw 8
    movwf division_counter, A
    
    
    division_loop:
	decf division_counter, 1, 0
	bcf CARRY
	rlcf Dividend_L, 1, 0
	rlcf Dividend_H, 1, 0
	
	
	
	movff Dividend_L, S1_L, A
	movff Dividend_H, S1_H, A
	
	
	
	movff Divisor_L, S2_L, A
	movff Divisor_H, S2_H, A
	
	call Subtraction_16bit


	btfsc S1_H, 7, 0 //  checking if positive
	goto skip_decimal_set 
	    



	movlw 0x07
	cpfslt division_counter, A
	goto set_decimal_7
	movlw 0x06
	cpfslt division_counter, A
	goto set_decimal_6
	movlw 0x05
	cpfslt division_counter, A
	goto set_decimal_5
	movlw 0x04
	cpfslt division_counter, A
	goto set_decimal_4
	movlw 0x03
	cpfslt division_counter, A
	goto set_decimal_3
	movlw 0x02
	cpfslt division_counter, A
	goto set_decimal_2
	movlw 0x01
	cpfslt division_counter, A
	goto set_decimal_1
	movlw 0x00
	cpfslt division_counter, A
	goto set_decimal_0
	
	set_decimal_7:
	bsf Decimal, 7, 0

	goto end_decimal_setting
	set_decimal_6:
	bsf Decimal, 6, 0
	goto end_decimal_setting
	set_decimal_5:
	bsf Decimal, 5, 0
	goto end_decimal_setting
	set_decimal_4:
	bsf Decimal, 4, 0
	goto end_decimal_setting
	set_decimal_3:
	bsf Decimal, 3, 0
	goto end_decimal_setting
	set_decimal_2:
	bsf Decimal, 2, 0
	goto end_decimal_setting
	set_decimal_1:
	bsf Decimal, 1, 0
	goto end_decimal_setting
	set_decimal_0:
	bsf Decimal, 0, 0
	goto end_decimal_setting
	end_decimal_setting:
	
	movff S1_H, Dividend_H, A
	movff S1_L, Dividend_L, A
	
	skip_decimal_set:
    movlw 0
    cpfseq division_counter, A
    goto division_loop
	
	
    movf Decimal, W, A

    
    mulwf Scaling, A
    
    return
    