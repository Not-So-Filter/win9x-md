;
; This is an infinite loop test.
;
InfiniteLoopGM:
		moveq	#signextendB($81),d0
		jsr	MegaPCM_PlaySample.l
		
.loop:
		bra.s	.loop