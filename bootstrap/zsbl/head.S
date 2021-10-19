// See LICENSE for license details.

#include "platform.h"
#include "smp.h"

  .section .text.init
  .option norvc
  .globl _start
_start:
  smp_pause(s1, s2)
  li sp, (DRAM_BASE + STACK_OFFSET)
  call _print
#ifdef WITH_SANCTUM
  call bootloader 
#endif
  smp_resume(s1, s2)
  csrr a0, mhartid
  li s0, DRAM_BASE
  jr s0

