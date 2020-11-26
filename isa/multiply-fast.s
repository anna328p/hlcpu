multiply_fast:
	mov ix, sp
	ldaox 2
	mov b, a
	ldaox 4
	mov c, a

	xor a, a
	mov iy, a
	mov d, a

loop:
	swp iy, a
	cmp 15
	jge :end
	swp iy, a

	mov a, c
	andi 1
	cmp 0
	jeq :next

	add c
	jmp :next

next:
	swp b, a
	shr 1
	swp b, a

	swp c, a
	shl 1
	swp c, a

	swp iy, a
	add 1
	swp iy, a

	jmp :loop
end:

	staox 2
	ret
