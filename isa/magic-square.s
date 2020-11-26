; Magic Square Checker
; Takes a memory address, passed on the stack

check:
	mov iy, sp
	ldaoy 2
	mov ix, a

	ldi 0
	mov b, a
	mov c, a
	mov d, a

	addox 0
	addox 1
	addox 2
	addox 3
	mov d, a

	ldi 0
	addox 4
	addox 5
	addox 6
	addox 7
	cmp a, d
	jne :false

	[...]

	ldi 1
	ret

false:
	ldi 0
	ret
