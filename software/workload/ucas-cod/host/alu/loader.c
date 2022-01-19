#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <limits.h>

#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "ALU.h"

typedef unsigned long long addr_t;
static long page_size = -1;
static int  mem_fd = -1;

#define MMIO_BASE    0x82000000
#define ROLE_BASE    (MMIO_BASE + (ROLE_ID << 20)) 

//offset of example adder MMIO REG
#define ALU_A         0x0
#define ALU_B         0x8
#define ALU_OP        0x10000
#define ALU_RES       0x20000
#define ALU_FLAGS     0x20008

uint32_t *alu_a, *alu_b, *alu_op,
	 *alu_res, *alu_flags; 

int total_count, failed_count;

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

void test_alu(void)
{
	extern int alu_ans_size;
	extern struct ALU_result alu_ans[];
	uint32_t result;
	union {
		struct {
			uint32_t overflow : 1;
			uint32_t carry    : 1;
			uint32_t zero     : 1;
                        uint32_t          : 29;
		};
		uint32_t bin;
	} flag;

	const char *op_name[] = {
		[0] = "AND",
		[1] = "OR",
		[2] = "ADD",
		[6] = "SUB",
		[7] = "SLT"
	};
	
	for (int i = 0; i < alu_ans_size; i++) {
		printf("%d/%d", i + 1, alu_ans_size);
		struct ALU_result alu = alu_ans[i];
		*alu_a = alu.a;
		*alu_b = alu.b;
		*alu_op = alu.type;
		result = *alu_res;
		flag.bin = *alu_flags;
		
		int flag_en = alu.type == ADD || alu.type == SUB;
		int zero_en = alu.type != SLT;
		int of_err = alu.overflow != flag.overflow;
		int cr_err = alu.carry != flag.carry;
		int zero_err = alu.zero != flag.zero;
		int calc_err = alu.result != result;
		
		if (calc_err || (zero_err && zero_en) || (flag_en && (of_err || cr_err))) 
		{
			puts(" failed");
			
			printf("Error, %s 0x%08x, 0x%08x\n", op_name[alu.type], alu.a, alu.b);
			
			if (calc_err)
				printf("expects result=0x%08x, but gets 0x%08x\n", alu.result, result);
			
			if (zero_err && zero_en)
				printf("expects zero=%d, but gets %d\n", alu.zero, flag.zero);
			
			if (of_err && flag_en)
				printf("expects overflow=%d, but gets %d\n", alu.overflow, flag.overflow);
			
			if (cr_err && flag_en)
				printf("expects carry=%d, but gets %d\n", alu.carry, flag.carry);
			
			failed_count++;
		}
		else {
			puts(" passed");
		}
		total_count++;
	}
}

int main(int argc, char *argv[])
{
	//set stdout with the property of no buffer
	setvbuf(stdout, NULL, _IONBF, 0);
	
	alu_a     = addr_map(ROLE_BASE + ALU_A);
	alu_b     = addr_map(ROLE_BASE + ALU_B);
	alu_op    = addr_map(ROLE_BASE + ALU_OP);
	alu_res   = addr_map(ROLE_BASE + ALU_RES);
	alu_flags = addr_map(ROLE_BASE + ALU_FLAGS);
  
	total_count = 0;
	failed_count = 0;
	
	test_alu();
  
	if (failed_count > 0) {
		printf("alu_eval: Test failed (%d/%d failed)\n", failed_count, total_count);
		return 1;
	}
	else {
		printf("alu_eval: Test passed (%d in total)\n", total_count);
		return 0;
	}

	addr_unmap(alu_a);
	addr_unmap(alu_b);
	addr_unmap(alu_op);
	addr_unmap(alu_res);
	addr_unmap(alu_flags);
	
	close(mem_fd);
	return 0;
}
