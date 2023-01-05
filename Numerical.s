#include <xc.inc>
global Subtraction_16bit, S1_H, S1_L, S2_H, S2_L
global Scaling, Dividend_H, Dividend_L, Divisor_H, Divisor_L, Scaling_by_Division_16bit_to_8bit
global ABS_H, ABS_L,Absolute_Value_2scomp
psect udata_acs

    S1_H: ds 1
    S1_L: ds 1
    S2_H: ds 1
    S2_L: ds 1
    
    ABS_H: ds 1
    ABS_L: ds 1
    
    Decimal: ds 1
    Scaling: ds 1
    Dividend_H: ds 1
    Dividend_L: ds 1
    Divisor_H: ds 1
    Divisor_L: ds 1
    division_counter: ds 1
    // bit 0 is used to track negative when performing division
    
psect numerical_code, class =CODE
    
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
   
 Absolute_Value_2scomp:
    btfss ABS_H, 7, 0
    goto skip_2s_un_complement
    
	movff ABS_L, S1_L, A
	movff ABS_H, S1_H, A
	movlw 0
	movwf S2_H, A
	movlw 1
	movwf S2_L, A

	call Subtraction_16bit

	comf S1_H, 0, 0
	movwf   ABS_H, A
	comf S1_L, 0, 0
	movwf   ABS_L, A
    
    skip_2s_un_complement:
    return
    
Scaling_by_Division_16bit_to_8bit:
    //used to map a value in the range 0 - Divisor to range 0 - Scaling
    movlw 0x00
    movwf Decimal, A // sets Decimal to 0
    movlw 8
    movwf division_counter, A
    
    
    division_loop:
	

	
	decf division_counter, 1, 0
	// decrements the vision counter (starts at 7 rather than 8 so matches the bit value index)
	// the division counter also corresponds to the bit number in Decimal
	bcf CARRY // clears carry
	rlcf Dividend_L, 1, 0 //rotates lower to the right
	rlcf Dividend_H, 1, 0 // rotates higher to the right with carry
	
	
	movff Dividend_L, S1_L, A
	movff Dividend_H, S1_H, A
	
	
	
	movff Divisor_L, S2_L, A
	movff Divisor_H, S2_H, A
	
	call Subtraction_16bit   ; Dividend - Divisor
	// if the above resut is negative, Divisor > Dividend: Dividend / Divisor < 1
	// cannot represent value has an integer

	btfsc S1_H, 7, 0 //  if bit 7 of S1_H high (negative 2's complement), skip next line
	goto skip_decimal_set 
	// the above skip ensures that the below is only carried out if Dividend > Divisor

	movlw 0x07
	cpfslt division_counter, A	// checks if division counter is 7
	goto set_decimal_7
	movlw 0x06
	cpfslt division_counter, A	// checks if division counter is 6
	goto set_decimal_6		
	movlw 0x05
	cpfslt division_counter, A	// checks if division counter is 5
	goto set_decimal_5
	movlw 0x04
	cpfslt division_counter, A	// checks if division counter is 4
	goto set_decimal_4
	movlw 0x03
	cpfslt division_counter, A	// checks if division counter is 3
	goto set_decimal_3
	movlw 0x02
	cpfslt division_counter, A	// checks if division counter is 2
	goto set_decimal_2
	movlw 0x01
	cpfslt division_counter, A	// checks if division counter is 1
	goto set_decimal_1
	movlw 0x00
	cpfslt division_counter, A	// checks if division counter is 0
	goto set_decimal_0
	
	
	// if Dividend > Divisor set the corresponding bit (division counter) in Decimal to 1
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
	
	// sets the subtracted value back into Dividend
	movff S1_H, Dividend_H, A
	movff S1_L, Dividend_L, A
	
	skip_decimal_set:
    
    movlw 0
    cpfseq division_counter, A // checks if division counter has reached 0
    goto division_loop
	
    movf Decimal, W, A // Decimal is moved to the W register

    
    mulwf Scaling, A  // W is multiplied by the scaling factor 
    
    return
    