multiply:
	mov ix, sp

	ldaox 2
	mov b, a
	ldaox 4
	mov c, a

loop:
	swp a, b
	cmp
	jnz :end

	sub 1
	swp a, b

	add c
	jmp :loop
end:

	staox 2
	ret
