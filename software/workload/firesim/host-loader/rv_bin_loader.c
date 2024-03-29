#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <memory.h>
#include <unistd.h>  
#include <sys/mman.h>  
#include <sys/types.h>  
#include <sys/stat.h>  
#include <fcntl.h>
#include <elf.h>
#include <signal.h>
#include <errno.h>

#include <inttypes.h>

#include <assert.h>

#define RV_CPU_MEM_TOTAL_SIZE		(1 << 32)
#define RV_CPU_MEM_SHOW_SIZE		(1 << 14)
#define RV_CPU_MEM_BASE_ADDR		0x4800000000
/* note:
 * 1. target bin-file is ./bare/nf_hello.bin generated by command "make nf_hello.bin" in ./bare
 * 2. argv should be "--dump nf_hello.bin +max-cycles=100000 +fesvr-step-size=128"
 * 3. FireSim-nf should run right after this program
 */
void *mem_map_base;
volatile uint32_t *mem_map_base_mmio;
volatile uint64_t *mem_map_base_mem;

int	fd;

void init_map();
void bin_loader(char *file);

int main(int argc, char *argv[]) {  
	//set stdout with the property of no buffer
	setvbuf(stdout, NULL, _IONBF, 0);

    const char *dump_filename = NULL;

    if (strcmp(argv[0], "--dump") == 0) {  // --dump <filename>
        dump_filename = argv[1];
    }
	/* mapping the RV memory space into the address space of this program */
	init_map();

	/* loading RV binary executable file to RV memory space */
	bin_loader(dump_filename);
}

void init_map() {
	int i;

	fd = open("/dev/mem", O_RDWR|O_SYNC);  
	if (fd == -1)  {  
		perror("init_map open failed:");
		exit(1);
	} 

	//physical mapping to virtual memory 
	mem_map_base = mmap(NULL, RV_CPU_MEM_TOTAL_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, RV_CPU_MEM_BASE_ADDR);
	
	if (mem_map_base == NULL) {  
		perror("init_map mmap failed:");
		close(fd);
		exit(1);
	}  

	mem_map_base_mmio = (uint32_t *)mem_map_base;
	mem_map_base_mem = (uint64_t *)mem_map_base;

	//clear 16KB memory region(why?)
	for(i = 0; i < RV_CPU_MEM_SHOW_SIZE / sizeof(int); i++)
		mem_map_base_mmio[i] = 0;
}

void bin_loader(char *file) {
	FILE *fp = fopen(file, "rb");
	assert(fp);
	int offset = 0;
	int sz = 1;
	char buf_temp[4];
	while(sz == 1){
		memset(buf_temp, 0, 4);
		fseek(fp, offset, SEEK_SET);
		sz=fread(buf_temp, 4, 1, fp);
		*(mem_map_base_mmio + (offset >> 2)) = *(uint32_t *)buf_temp;
		offset += 4;
	}
	fclose(fp);
}
