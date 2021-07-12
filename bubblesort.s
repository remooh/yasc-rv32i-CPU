.globl __start

__start:
	li a0, 0		# a0 -> base addr
	li a1, 128		# a1 -> num elements

	addi s0, x0, 0		# big loop counter to 0
	addi s1, x0, 0		# small loop counter to 0

big_loop:
	mv t2, a0		# base addr to t2
	addi s0, s0, 1		# increate big loop counter
	addi s1, x0, 0		# small loop counter to 0
small_loop:
	addi t2, t2, 4		# next addr
	addi s1, s1, 1		# increate small loop counter
	
	lw t0, -4(t2)
	lw t1, 0(t2)
	
	ble t0, t1, skip	# branch if less or equal
swap:
	sw t1, -4(t2)
	sw t0, 0(t2)
skip:
	sub t3, a1, s0		# set t3 = num elements - big loop counter
	blt s1, t3, small_loop	# branch if small loop counter < t3

	blt s0, a1, big_loop	# branch if big loop counter < num elements
	
loop:
	j loop
