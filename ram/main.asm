

	phase $FFFF0000
RAM_Start:
		ds.b $8000
MouseBuffer:	ds.b 1
		ds.b $7DFB
GameMode:	ds.l 1
StackRAM:
		ds.b $200
RAM_End:
	dephase
	!org 0