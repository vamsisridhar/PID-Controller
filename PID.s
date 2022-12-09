#include <xc.inc>
global Timer_Setup, PID_Cycle
extrn	LCD_Write_Hex, UART_Transmit_Message, UART_Write_Hex
    
psect adc_code, class=CODE

Timer_Setup:
    movlw	10000001B	; Set timer0 to 16-bit, Fosc/4/25
    movwf	T1CON, A	; = 62.5KHz clock rate, approx 1sec rollover

    bsf	TMR1IE		; Enable timer0 interrupt
    bsf	GIE		; Enable all interrupts
    return
    
PID_Cycle:
    btfss	TMR1IF		; check that this is timer0 interrupt
    retfie	f		; if not then return
    movf    0x00
    call UART_Write_Hex
    bcf	TMR1IF		; clear interrupt flag
    retfie	f		; fast return from interrupt
    return