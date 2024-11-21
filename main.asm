; =============================================================
;
; Windows 9X - Mega Drive Edition
; Written by Filter
;
; =============================================================

	include	"constants.asm"
	include	"macros.asm"
	include	"macrosetup.asm"
	include	"ram/main.asm"
	include	"errorhandler/Debugger.asm"

StartOfRom:
		dc.l StackRAM
		dc.l EntryPoint
		dc.l ErrorTrap		; Bus error
		dc.l ErrorTrap	; Address error (4)
		dc.l ErrorTrap	; Illegal instruction
		dc.l ErrorTrap		; Division by zero
		dc.l ErrorTrap		; CHK exception
		dc.l ErrorTrap		; TRAPV exception (8)
		dc.l ErrorTrap	; Privilege violation
		dc.l ErrorTrap		; TRACE exception
		dc.l ErrorTrap	; Line-A emulator
		dc.l ErrorTrap	; Line-F emulator (12)
		dc.l ErrorTrap	; Unused (reserved)
		dc.l ErrorTrap	; Unused (reserved)
		dc.l ErrorTrap	; Unused (reserved)
		dc.l ErrorTrap	; Unused (reserved) (16)
		dc.l ErrorTrap	; Unused (reserved)
		dc.l ErrorTrap	; Unused (reserved)
		dc.l ErrorTrap	; Unused (reserved)
		dc.l ErrorTrap	; Unused (reserved) (20)
		dc.l ErrorTrap	; Unused (reserved)
		dc.l ErrorTrap	; Unused (reserved)
		dc.l ErrorTrap	; Unused (reserved)
		dc.l ErrorTrap	; Unused (reserved) (24)
		dc.l ErrorTrap	; Spurious exception
		dc.l ErrorTrap		; IRQ level 1
		dc.l ErrorTrap		; IRQ level 2
		dc.l ErrorTrap		; IRQ level 3 (28)
		dc.l ErrorTrap		; IRQ level 4 (horizontal retrace interrupt)
		dc.l ErrorTrap		; IRQ level 5
		dc.l V_Int		; IRQ level 6 (vertical retrace interrupt)
		dc.l ErrorTrap		; IRQ level 7 (32)
		dc.l ErrorTrap		; TRAP #00 exception
		dc.l ErrorTrap		; TRAP #01 exception
		dc.l ErrorTrap		; TRAP #02 exception
		dc.l ErrorTrap		; TRAP #03 exception (36)
		dc.l ErrorTrap		; TRAP #04 exception
		dc.l ErrorTrap		; TRAP #05 exception
		dc.l ErrorTrap		; TRAP #06 exception
		dc.l ErrorTrap		; TRAP #07 exception (40)
		dc.l ErrorTrap		; TRAP #08 exception
		dc.l ErrorTrap		; TRAP #09 exception
		dc.l ErrorTrap		; TRAP #10 exception
		dc.l ErrorTrap		; TRAP #11 exception (44)
		dc.l ErrorTrap		; TRAP #12 exception
		dc.l ErrorTrap		; TRAP #13 exception
		dc.l ErrorTrap		; TRAP #14 exception
		dc.l ErrorTrap		; TRAP #15 exception (48)
		dc.l ErrorTrap		; Unused (reserved)
		dc.l ErrorTrap		; Unused (reserved)
		dc.l ErrorTrap		; Unused (reserved)
		dc.l ErrorTrap		; Unused (reserved) (52)
		dc.l ErrorTrap		; Unused (reserved)
		dc.l ErrorTrap		; Unused (reserved)
		dc.l ErrorTrap		; Unused (reserved)
		dc.l ErrorTrap		; Unused (reserved) (56)
		dc.l ErrorTrap		; Unused (reserved)
		dc.l ErrorTrap		; Unused (reserved)
		dc.l ErrorTrap		; Unused (reserved)
		dc.l ErrorTrap		; Unused (reserved) (60)
		dc.l ErrorTrap		; Unused (reserved)
		dc.l ErrorTrap		; Unused (reserved)
		dc.l ErrorTrap		; Unused (reserved)
		dc.l ErrorTrap		; Unused (reserved) (64)
Header:
		dc.b "SEGA MEGA DRIVE " ; Console name
		dc.b "BUILD 11/17/2024" ; Copyright holder and release date
		dc.b "WINDOWS 9X - MEGA DRIVE EDITION                 " ; Domestic name
		dc.b "WINDOWS 9X - MEGA DRIVE EDITION                 " ; International name
		dc.b "GM XXXXXXXX-00"   ; Version
		dc.w 0			; Checksum
		dc.b "J               " ; I/O Support
		dc.l StartOfRom		; Start address of ROM
		dc.l EndOfRom-1		; End address of ROM
		dc.l RAM_Start		; Start address of RAM
		dc.l RAM_End-1		; End address of RAM
		dc.b "    "		; Backup RAM ID
		dc.l $20202020		; Backup RAM start address
		dc.l $20202020		; Backup RAM end address
		dc.b "            "	; Modem support
		dc.b "This build is provided to XXXXXXXXXXXXX."	; Notes
		dc.b "JUE             " ; Country code (region)
EndOfHeader:

; ===========================================================================
; Freeze the 68000.
ErrorTrap:
		bra.s	ErrorTrap	; Loop indefinitely.
; ===========================================================================

EntryPoint:
		moveq	#$F,d0					; get only the version number
		and.b	z80_version.l,d0			; load hardware version/region
		beq.s	SG_NoTMSS				; if the version is 0, branch (no TMSS in this machine)
		move.l	#"SEGA",security_addr.l		; give TMSS the string "SEGA" so it unlocks the VDP

SG_NoTMSS:
		move.w	#$100,d1				; prepare Z80 value/VDP register increment
		move.w	d1,z80_bus_request.l			; request Z80 to stop
		clr.w	z80_reset.l			; request Z80 reset on (resets YM2612)
		lea	vdp_data_port.l,a5			; load VDP data port
		lea	$11(a5),a4				; load PSG port
		move.b	#$9F,(a4)				; mute all PSG channels
		move.b	#$BF,(a4)				; ''
		move.b	#$DF,(a4)				; ''
		move.b	#$FF,(a4)				; ''
		move.w	d1,z80_reset.l			; request Z80 reset off

		jsr	MegaPCM_LoadDriver.l
		lea	SampleTable.l,a0
		jsr	MegaPCM_LoadSampleTable.l
		tst.w	d0                      ; was sample table loaded successfully?
		beq.s	.SampleTableOk          ; if yes, branch
		illegal
.SampleTableOk:

		moveq	#$60,d0
		move.b	d0,IoCtrl1.l	; 1P control port
		move.b	d0,IoData1.l	; 1P data port

		move.l	#InfiniteLoopGM,GameMode.w

GameModeLoop:
		movea.l	GameMode.w,a0
		jsr	(a0)
		bra.s	GameModeLoop

		; interrupts
		include	"interrupts/vertical.asm"

		; controllers
		include	"controllers/mouse.asm"

		; objects and object code
		include	"gamemodes/infinite loop.asm"

		; objects and object code
		include	"objects/process.asm"

		; sound
		include	"sound/MegaPCM.asm"
		include	"sound/SampleTable.asm"
		
; ==============================================================
; --------------------------------------------------------------
; Debugging modules
; --------------------------------------------------------------

		even
		include	"errorhandler/ErrorHandler.asm"

; --------------------------------------------------------------
; WARNING!
;	DO NOT put any data from now on! DO NOT use ROM padding!
;	Symbol data should be appended here after ROM is compiled
;	by ConvSym utility, otherwise debugger modules won't be able
;	to resolve symbol names.
; --------------------------------------------------------------

EndOfRom: