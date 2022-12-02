#include <xc.inc>

global  ADC_Init, ADC_Setup_X, ADC_Setup_Y, ADC_Read    
   
psect	udata_acs, space=1
READX EQU 5
READY EQU 2
DRIVEA EQU 4
DRIVEB EQU 5
 
 
psect	adc_code, class=CODE
    
ADC_Init:
    bsf	TRISF, READX, A ; X input (BOTTOM READ-X)
    bsf	TRISF, READY, A ; Y input (LEFT READ-Y)
    
    bcf TRISE, DRIVEA, A ; DRIVE-A output -- determines X input
    bcf	TRISE, DRIVEB, A ; DRIVE-B output -- determines Y input
    return
 
ADC_Setup_X: ; measure from RF5
    bsf	LATE, DRIVEA, A
    bcf	LATE, DRIVEB, A
    
    banksel ANCON1
    bsf	ANSEL10	    ; set AN10 to analog
    movlb 0x00
    movlw   00101001B	    ; 0, 01010 - select AN10, 
    movwf   ADCON0, A	    ; and turn ADC on
    movlw   0x00	    ; Select 0V positive reference
    movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
    movlw   0xF6	    ; Right justified output
    movwf   ADCON2, A	    ; Fosc/64 clock and acquisition times
    return

ADC_Setup_Y: ; measure from RF2
    bcf	LATE, DRIVEA, A
    bsf	LATE, DRIVEB, A
    banksel ANCON0
    bsf	ANSEL7	    ; set AN7 to analog
    movlb 0x00
    movlw   00011101B	    ; 0, 01010 - select AN10, 
    movwf   ADCON0, A	    ; and turn ADC on
    movlw   0x00	    ; Select 0V positive reference
    movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
    movlw   0xF6	    ; Right justified output
    movwf   ADCON2, A	    ; Fosc/64 clock and acquisition times
    return
	
	
ADC_Read:
	bsf	GO	    ; Start conversion by setting GO bit in ADCON0
adc_loop:
	btfsc   GO	    ; check to see if finished
	bra	adc_loop
	return

end