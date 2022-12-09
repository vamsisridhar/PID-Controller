#include <xc.inc>
global Numerical_Setup, IIR_Filter_X,IIR_Filter_Y 
psect udata_acs
 
    IIR_Sum_X:  ds 1
    IIR_Input_X:  ds 1
    IIR_Sum_Y:  ds 1
    IIR_Input_Y:  ds 1
psect numerical_code, class =CODE
Numerical_Setup:
    movlw 0x00
    movwf  IIR_Sum_X, A
    movwf  IIR_Sum_Y, A
    return

IIR_Filter_X:

    rrcf    IIR_Sum_X, 1, 0

    movwf   IIR_Input_X, A
    rrcf    IIR_Input_X, 1, 0
    rrcf    IIR_Input_X, 0, 0

    addwf   IIR_Sum_X, 1, 0
    movf    IIR_Sum_X, W, A

    return
    
    
IIR_Filter_Y:


rrcf    IIR_Sum_Y, 1, 0
    rrcf    IIR_Sum_Y, 1, 0
movwf   IIR_Input_Y, A
    rrcf    IIR_Input_Y, 0, 0
addwf   IIR_Sum_Y, 1, 0
;movf    IIR_Sum_Y, W, A

return