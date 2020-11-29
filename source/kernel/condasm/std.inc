	.xlist
;
;------------------------------------------------------------------------------
;
; Conditional assembly switch
HYBRID			equ	-1	;DOS1/DOS2 hybrid system
STURBO			equ	-1	;support super turbo mode (for MSXturboR)
BUILTIN			equ	-1	;built-in system
EX_RUSSIAN		equ	-1	; Exclude support for Russian keyboard
DEBUG			equ	0	; SET to -1 to enable debug/trace
DISABLE_MEM_SCAN	equ	0	; DISABLE MEM BANK SCANNING - AVOID BRITTLE STACK WALKING CODE (see MEM_CHK)
;
;-----------------------------------------------------------------------------
;
	.list
;
