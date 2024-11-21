; ==============================================================
; --------------------------------------------------------------
; Vertical interrupts
; --------------------------------------------------------------
V_Int:
		movem.l	d0-a6,-(sp)	; push everything into stack
		bsr.w	ReadMouse	; read mouse controls
		movem.l	(sp)+,d0-a6	; restore everything from stack
		rte