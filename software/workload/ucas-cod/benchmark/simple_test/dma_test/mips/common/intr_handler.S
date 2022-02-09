.data
last_tail_ptr:
        .word 0

.globl intr_handler
	.align  2
	.type intr_handler, @function
	.section .exception

intr_handler:
	lw	$k0, (dma_mmio)
	li	$k1, 0x1
	sw	$k1, 20($k0)
	lw	$k1, 8($k0)
	lw	$k0, 16($k0)
	addi    $k0, $k0, -512
	beqz    $k0, SIM
	srl     $k1, $k1, 12
	j	return_label
SIM:
	srl     $k1, $k1, 9
return_label:
	lw	$k0, (last_tail_ptr)
	sw	$k1, (last_tail_ptr)
	sub     $k1, $k1, $k0
	lw	$k0, (dma_buf_stat)
	sub	$k1, $k0, $k1
	sw	$k1, (dma_buf_stat)

	eret
