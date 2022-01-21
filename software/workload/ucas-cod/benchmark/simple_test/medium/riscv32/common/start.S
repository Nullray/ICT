.globl global_result
.globl start 
.type start, @function

start:
  li sp, 0x4000
  j continued 
  nop

global_result:
  .word 0xffffffff

continued:
  jal main
  jal hit_good_trap
