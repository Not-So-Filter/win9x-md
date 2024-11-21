
; ---------------------------------------------------------------
SampleTable:
	;			type			pointer		Hz
	dcSample	TYPE_PCM, 		mssound, 	22025		; $81
	dcSample	TYPE_PCM, 		tada, 		22025		; $82
	dcSample	TYPE_PCM, 		chimes, 	22025		; $83
	dc.w	-1	; end marker

; ---------------------------------------------------------------
	incdac	mssound, "pcm/mssound.pcm"
	incdac	tada, "pcm/tada.pcm"
	incdac	chimes, "pcm/chimes.pcm"
	even
