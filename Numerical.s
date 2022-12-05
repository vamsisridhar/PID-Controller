#include <xc.inc>
    
;Integration
    ; trapezium rule
    ; global var integral
    ; integral += (x_n + x_(n-1)) * (dt/2)
;Differentiation
    ; dx_n = x_n - x_(n-1)/dt
;Exponential Function
    
; Floating point addition
    ; b1 = m1*2^e1-22 where m1 is signed, e1 >= 0
    ; b2 = m2*2^e2-22 where m2 is signed, e2 >= 0
    ; b1 + b2:
    ;	if e2 > e1
	;right bit shift on m1 by e1 + e2
	;signed addition of m1_new + m2
	;e = e2
    ; b1 + b2 = (m2 + m1_new) * 2^e2-22

; Floating point signed multiplication
    ; 24 bit by 24 bit signed multiplication m1 * m2 = m3
    ; truncate to 24 bits m3_new
    ; e = e1 + e2
    ; m3_new * 2^(e1+e2 - 22)
    
; Floating point division
    ; right shift counter: rf
    ; quotient 24 bit: m3
    ; if e1-e2 < 0: rf += e2 - e1
    ; if m1 < m2:
	;right shift m1: rf += 1
	;loop m2 until m1 < m2 and add the loop count to current m3 bit
	
	;repeat above until m3 on last bit
    ; 
psect udata_acs
Numerical_integral: 


