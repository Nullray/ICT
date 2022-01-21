.globl start
.globl global_result

#define goto(label) \
	addiu $k0, $zero, 1; \
	bne $k0, $zero, label

start:
	goto(real_start)
	
global_result:
	.long 0xffffffff

real_start:
	li $a0, 0
	li $a1, 100
loop1:
	sw $a0, 200($a0)
	addiu $a0, $a0, 4
	bne $a0, $a1, loop1
	

	li $a0, 0
loop2:
	lw $a2, 200($a0)
	sw $a2, 300($a0)
	addiu $a0, $a0, 4
	bne $a0, $a1, loop2


	li $a0, 0
check:
	lw $a2, 300($a0)
	bne $a2, $a0, bad_trap
	addiu $a0, $a0, 4
	bne $a0, $a1, check
	
	goto(good_trap)

bad_trap:
	li $a0, 1
	goto(exit)

good_trap:
	li $a0, 0
exit:
	#sw $a0, global_result
	sw $a0, 0xc($zero)
	#li $a1, 0x40000000
	#sw $a0, 0($a1)
spin:
	goto(spin)

