
if DEBUG
dbg.text	MACRO	t
		LOCAL	skip
		LD	D,D
		JR	skip
		DB	t
skip:
		ENDM

dbg.break	MACRO

		LD	B, B
		JR	$+2

		ENDM

dbg.prt		MACRO	txt

		LOCAL	s1, s2
		ld	de, s1
		call	PRINT
		jr	s2
s1:		DB	txt, 13, 10, '$'
s2:
		ENDM
else
dbg.text	MACRO	t
		ENDM

dbg.break	MACRO
		ENDM

dbg.prt		MACRO	txt
		ENDM
endif
