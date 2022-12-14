#include <xc.inc>
global Numerical_Setup, IIR_Filter_X,IIR_Filter_Y 
global IIR_Sum_X_L, IIR_Sum_X_H, IIR_Sum_Y_L, IIR_Sum_Y_H
global Subtraction_16bit, S1_H, S1_L, S2_H, S2_L
global Division_by_Rotation_Signed_16_bit, D1_H, D1_L
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
    btfss CARRY
    incfsz S2_H, 1, 0
    subwf S1_H, 1, 0
   
    return
    
Division_by_Rotation_Signed_16_bit:
    bcf	negative_register, 0, 0
    btfss D1_H, 7, 0
    goto apply_scaling
    // skips to apply_scaling if positive
    bcf D1_H, 7, 0
    bsf	negative_register, 0, 0
    
    apply_scaling:
    bcf	CARRY
    
    rrcf D1_H, 1, 0
    rrcf D1_L, 1, 0
    
    bcf CARRY
    
    rrcf D1_H, 1, 0
    rrcf D1_L, 1, 0
    
    btfsc negative_register, 0, 0
    bsf D1_H, 7, 0

    bcf	negative_register, 0, 0
