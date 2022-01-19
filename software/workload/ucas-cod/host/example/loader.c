#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

typedef unsigned long long addr_t;
static long page_size = -1;
static int  mem_fd = -1;

#define MMIO_BASE    0x82000000
#define ROLE_BASE    (MMIO_BASE + (ROLE_ID << 20)) 

//offset of example adder MMIO REG
#define OP1          0x0
#define OP2          0x8
#define RES          0x10000

void *addr_map(addr_t addr)
{
	if (mem_fd == -1) {
		mem_fd = open("/dev/mem", O_RDWR);
	}
	if (page_size == -1) {
		page_size = sysconf(_SC_PAGESIZE);
	}
	
	addr_t addr_aligned = addr & (~(page_size - 1));
	addr_t offset       = addr - addr_aligned;

	void *addr_alloc = mmap(NULL, page_size, PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, addr_aligned);
	return (void *)((addr_t)addr_alloc + offset);
}

void *addr_unmap(void *addr)
{
	addr_t addr_aligned = (addr_t)addr & (~(page_size - 1));
	munmap((void *)addr_aligned, page_size);
}

int main(int argc, char *argv[])
{
	//set stdout with the property of no buffer
	setvbuf(stdout, NULL, _IONBF, 0);
  
	unsigned *result  = addr_map(ROLE_BASE + RES);
	unsigned *operand = addr_map(ROLE_BASE + OP1);
	
	// iterate from 0 to 0xff to test the 8-bit adder
	for (unsigned operand1 = 0; operand1 < 0x100; operand1++) {
		for (unsigned operand2 = 0; operand2 < 0x100; operand2++) {
			*operand = operand1;
			*(operand + 2) = operand2;
			__asm__("nop");
			
			unsigned result_ref = (operand1 + operand2) & 0xff;
			unsigned result_dut = *result;
			
			if (result_ref != result_dut) {
				printf("0x%x + 0x%x should be 0x%x, but get 0x%x\n", operand1, operand2, result_ref, result_dut);
				printf("FPGA evaluation failed.\n");
				exit(1);
			}
		}
	}
	printf("FPGA evaluation succeeded.\n");
	
	addr_unmap(result);
	addr_unmap(operand);
	
	close(mem_fd);
	return 0;
}
