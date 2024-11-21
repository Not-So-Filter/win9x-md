; Reads a mouse packet
; d0.w = 0 on success
;       -1 on failure

ReadMouse:
	; I/O data port to read from
	; Use IoData2 for player 2
	lea	IoData1.l,a0

	; Buffer to store the nibbles
	; (we use up one byte per nibble)
	lea	MouseBuffer.w,a1

	; Look-up table, see below
	lea	.Table(pc),a2

	; Keep Z80 out of the 68000 bus
	stopZ80

	; Now loop through all nibbles
	; (the -1 is because of DBF)
	moveq	#9-1,d0
.Loop:

	; Tell mouse to send next nibble
	; and wait for it to be ready (if
	; it takes too long we bail out)
	move.b	(a2)+,(a0)
	move.w	#$100-1,d7
.Wait:
	moveq	#$10,d6	; Mask out bit 4 and
	and.b	(a0),d6	; check if it matches
	cmp.b	(a2),d6	; what we want
	beq.s	.GotIt

	dbf	d7,.Wait   ; Keep waiting if not,
	bra.s	.Error	  ; or throw error if we
						; waited way too long

	; Got the nibble, store it into a
	; buffer and move onto the next one
.GotIt:
	moveq	#$F,d6	; Mask out the nibble
	and.b	(a0),d6	; and store it into
	move.b	d6,(a1)+   ; the buffer

	lea	1(a2),a2   ; Advance look-up table
	dbf	d0,.Loop   ; Keep looping

	move.b	#$60,(a0) ; Leave mouse alone
	startZ80		   ; Let Z80 continue
	moveq	#0,d0	  ; Success!
	rts				 ; End of subroutine

.Error:
	move.b	#$60,(a0)  ; Reset mouse just in case
	startZ80		   ; Let Z80 continue
	moveq	#-1,d0	 ; Failure...
	rts				 ; End of subroutine

; Look-up table used in the loop above
; 1st byte is what to write, 2nd byte is
; what to wait for (in bit 4)
.Table:
	dc.b	$20,$10	; 1st nibble
	dc.b	$00,$00	; 2nd nibble
	dc.b	$20,$10	; 3rd nibble
	dc.b	$00,$00	; 4th nibble
	dc.b	$20,$10	; 5th nibble
	dc.b	$00,$00	; 6th nibble
	dc.b	$20,$10	; 7th nibble
	dc.b	$00,$00	; 8th nibble
	dc.b	$20,$10	; 9th nibble