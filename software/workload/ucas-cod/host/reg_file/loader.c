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

typedef unsigned long long addr_t;
static long page_size = -1;
static int  mem_fd = -1;

#define MMIO_BASE    0x82000000
#define ROLE_BASE    (MMIO_BASE + (ROLE_ID << 20)) 

//offset of example adder MMIO REG
#define WADDR        0x0
#define WDATA        0x8
#define WEN          0x10000
#define RADDR1       0x20000
#define RADDR2       0x20008
#define RDATA1       0x30000
#define RDATA2       0x30008

//custom operations
#define RD    0
#define RS1   1
#define RS2   2
#define W     1
#define N     0

uint32_t *rf_waddr, *rf_wdata, *rf_wen,
	 *rf_raddr1, *rf_raddr2, 
	 *rf_rdata1, *rf_rdata2;

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

void reg_write(uint32_t addr, uint32_t data, uint32_t wen)
{
	*rf_wen = wen;
	*rf_waddr = addr;  // Change addr first to avoid writing to wrong reg.
	*rf_wdata = data;
	*rf_wen = N;
}


uint32_t reg_read(uint32_t addr, uint32_t port)
{
	switch (port) {
		case RS1:
			*rf_raddr1 = addr;
			return *rf_rdata1;
		
		case RS2:
			*rf_raddr2 = addr;
			return *rf_rdata2;
	}
	return 0xffffffff;
}


void test_regfile(void)
{
	uint32_t data = (uint32_t)random(), prev_data = 0;
	uint32_t rs1_data, rs2_data;
	
	puts("Test r/w on r0");
	reg_write(0, data, W);
	if ((rs1_data = reg_read(0, RS1)) != 0 || (rs2_data = reg_read(0, RS2)) != 0) {
		printf("Error: r0 has non-zero data (rs1=%08x, rs2=%08x)\n", rs1_data, rs2_data);
		failed_count++;
	}
	
	total_count++;
	
	puts("Test r/w on r1~r31");
	for (int i = 1; i < 32; i++) {
		do { data = (uint32_t)random(); } while (data == prev_data);
		printf("writing %08x to r%d wen=1\n", data, i);

		reg_write(i, data, W);
		printf("checking data from r%d\n", i);
		
		if ((rs1_data = reg_read(i, RS1)) != data || (rs2_data = reg_read(i, RS2)) != data) {
			printf("Error: r%d does not have written data=%08x (rs1=%08x, rs2=%08x)\n", i, data, rs1_data, rs2_data);
			failed_count++;
		}
		
		if (reg_read(i - 1, RS1) != prev_data) {
			printf("Error: r%d's data has been overwritten\n", i - 1);
			failed_count++;
		}
		prev_data = data;
		total_count++;
	}
	
	puts("Test wen on r1~r31");
	for (int i = 1; i < 32; i++) {
		rs1_data = reg_read(i, RS1);
		do { data = (uint32_t)random(); } while (data == rs1_data);
		printf("writing %08x to r%d wen=0\n", data, i);
		
		reg_write(i, data, N);
		if ((rs1_data = reg_read(i, RS1)) == data || (rs2_data = reg_read(i, RS2)) == data) {
			printf("Error: r%d has written data under wen=0 (rs1=%08x, rs2=%08x)\n", i, rs1_data, rs2_data);
			failed_count++;
		}
		total_count++;
	}
}

int main(int argc, char *argv[])
{
	//set stdout with the property of no buffer
	setvbuf(stdout, NULL, _IONBF, 0);
	
	rf_waddr  = addr_map(ROLE_BASE + WADDR);
	rf_wdata  = addr_map(ROLE_BASE + WDATA);
	rf_wen    = addr_map(ROLE_BASE + WEN);
	rf_raddr1 = addr_map(ROLE_BASE + RADDR1);
	rf_raddr2 = addr_map(ROLE_BASE + RADDR2);
	rf_rdata1 = addr_map(ROLE_BASE + RDATA1);
	rf_rdata2 = addr_map(ROLE_BASE + RDATA2);
  
	total_count = 0;
	failed_count = 0;
	
	test_regfile();
  
	if (failed_count > 0) {
		printf("reg_file_eval: Test failed (%d/%d failed)\n", failed_count, total_count);
		return 1;
	}
	else {
		printf("reg_file_eval: Test passed (%d in total)\n", total_count);
		return 0;
	}

	addr_unmap(rf_waddr);
	addr_unmap(rf_wdata);
	addr_unmap(rf_wen);
	addr_unmap(rf_raddr1);
	addr_unmap(rf_raddr2);
	addr_unmap(rf_rdata1);
	addr_unmap(rf_rdata2);
	
	close(mem_fd);
	return 0;
}
