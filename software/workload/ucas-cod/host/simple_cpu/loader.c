//==========================================================
// MIPS CPU binary executable file loader
//
// Main Function:
// 1. Loads binary excutable file into distributed memory
// 2. Waits MIPS CPU for finishing program execution
//
// Author:
// Yisong Chang (changyisong@ict.ac.cn)
//
// Revision History:
// 14/06/2016	v0.0.1	Add cycle counte support
// 24/01/2018	v0.0.2	ARMv8 support to avoid unalignment fault
//==========================================================
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

#include <assert.h>

#include <inttypes.h>

#define MMIO_BASE    0x82000000
#define ROLE_BASE    (MMIO_BASE + (ROLE_ID << 20)) 

#define IDEAL_MEM_BASE_ADDR        0x00000
#define RESET_REG_BASE_ADDR        0x10000

#define MMAP_TOTAL_SIZE            (1 << 16)

#define IDEAL_MEM_SIZE		   (1 << 12)
#define EXEC_FLAG_OFFSET           0x00000003

// The number of times to access 0xc to get the running result after a sleep
#define RETRY_TIMES 10
// The seconds between every two access to 0xc
#define SLEEP_TIME 1

void *map_base, *reset_map_base;
volatile uint32_t *map_base_mmio, *reset_base;
volatile uint64_t *map_base_mem;
int	fd;

static int verbose = 0;

static FILE *log_fp = NULL;
#define log(fmt, ...) do { if (verbose) fprintf(log_fp, fmt, ## __VA_ARGS__); } while(0)

#define mips_addr(p) (map_base + (uintptr_t)(p))

#define ALIGN_MASK_8_BYTES			0x07
#define ALIGN_MASK_4_BYTES			0x03

void loader(char *file) 
{
	FILE *fp = fopen(file, "rb");
	assert(fp);

	Elf32_Ehdr *elf;
	Elf32_Phdr *ph = NULL;

	int i;
	uint8_t buf[4096];
	uint8_t buf_temp[16];

	// the program header should be located within the first
	// 4096 byte of the ELF file
	fread(buf, 4096, 1, fp);
	elf = (void *)buf;

	// TODO: fix the magic number with the correct one
	const uint32_t elf_magic = 0x464c457f; // 0xBadC0de;
	uint32_t *p_magic = (uint32_t *)buf;

	// check the magic number
	assert(*p_magic == elf_magic);

	// PC Reset value MUST be 0 for simple CPU
	assert(elf->e_entry == 0);

	for(i = 0, ph = (void *)buf + elf->e_phoff; i < elf->e_phnum; i ++) {
		// scan the program header table, load each segment into memory
		if(ph[i].p_type == PT_LOAD) {
			uint64_t va = ph[i].p_vaddr;
			
			if(va >= MMAP_TOTAL_SIZE)
				continue;

			uint64_t size = 0;

			// TODO: read the content of the segment from the ELF file
			// to the memory region [VirtAddr, VirtAddr + FileSiz)

			//align va to 64-bit boundary
			if(va & ALIGN_MASK_8_BYTES)
			{
				assert((va & ALIGN_MASK_4_BYTES) == 0);
				assert(ph[i].p_filesz >= 4);

				memset(buf_temp, 0, 16);
				fseek(fp, ph[i].p_offset, SEEK_SET);
				fread(buf_temp, 4, 1, fp);		//read out unaligned size to temporal buffer

				for(int i = 0; i < 4; i++)
					log("%02x ", buf_temp[i]);

				log("\n");

				*(map_base_mmio + (va >> 2)) = *(uint32_t *)buf_temp;

				va += 4;
				size += 4;
			}

			//aligned copy
			while((size + 8) <= ph[i].p_filesz)
			{
				memset(buf_temp, 0, 16);
				fseek(fp, ph[i].p_offset + size, SEEK_SET);
				fread(buf_temp, 8, 1, fp);		//read out unaligned size to temporal buffer

				for(int i = 0; i < 8; i++)
					log("%02x ", buf_temp[i]);

				log("\n");

				*(map_base_mem + (va >> 3)) = *(uint64_t *)buf_temp;

				va += 8;
				size += 8;
			}

			//check if remaining a 32-bit word
			if(size != ph[i].p_filesz)
			{
				uint64_t lastsz = ph[i].p_filesz - size;

				assert((va & ALIGN_MASK_4_BYTES) == 0);
				assert(lastsz == 4);

				memset(buf_temp, 0, 16);
				fseek(fp, ph[i].p_offset + size, SEEK_SET);
				fread(buf_temp, 4, 1, fp);

				for(int i = 0; i < 4; i++)
					log("%02x ", buf_temp[i]);

				log("\n");

				*(map_base_mmio + (va >> 2)) = *(uint32_t *)buf_temp;
				va += 4;
			}

			// TODO: zero the memory region
			// [VirtAddr + FileSiz, VirtAddr + MemSiz)
			
			uint64_t rest = ph[i].p_memsz - ph[i].p_filesz;
			uint64_t zero_sz = 0;
			if (zero_sz < rest && (va & ALIGN_MASK_8_BYTES)) {
				*(map_base_mmio + (va >> 2)) = 0;
				va += 4;
				zero_sz += 4;
			}
			while ((zero_sz + 8) <= rest) {
				*(map_base_mem + (va >> 3)) = 0;
				va += 8;
				zero_sz += 8;
			}
			if (zero_sz < rest) {
				if ((zero_sz + 4) != rest) {
					puts("Unaligned");
					exit(-1);
				}
				*(map_base_mmio + (va >> 2)) = 0;
			}
		}
	}

	fclose(fp);
}

void init_map()
{
	int i;

	fd = open("/dev/mem", O_RDWR|O_SYNC);  
	if (fd == -1)  {
		perror("init_map open failed:");
		exit(1);
	} 

	//physical mapping to virtual memory 
	map_base = mmap(NULL, MMAP_TOTAL_SIZE, PROT_READ | PROT_WRITE, 
			MAP_SHARED, fd, (ROLE_BASE + IDEAL_MEM_BASE_ADDR));

	reset_map_base = mmap(NULL, MMAP_TOTAL_SIZE, PROT_READ | PROT_WRITE, 
			MAP_SHARED, fd, (ROLE_BASE + RESET_REG_BASE_ADDR));
	
	if (map_base == NULL || reset_map_base == NULL) {  
		perror("init_map mmap failed:");
		close(fd);
		exit(1);
	}  

	map_base_mmio = (uint32_t *)map_base;
	map_base_mem = (uint64_t *)map_base;
	reset_base = (uint32_t *)reset_map_base;

	//clear 16KB memory region
	for(i = 0; i < IDEAL_MEM_SIZE / sizeof(int); i++)
		map_base_mmio[i] = 0;
}

void reset(int val) 
{
	*reset_base = val;
}

int wait_for_finish()
{
	uint32_t rst = -1;
	for (int i = 0; i < RETRY_TIMES; i++) {
		sleep(SLEEP_TIME);
		rst = *(map_base_mmio + EXEC_FLAG_OFFSET);
		log("#%d access to result (= %u)\n", i + 1, rst);
		
		if (rst == 0 || rst == 1)
			return rst;
	}
	
	puts("simple CPU core ran time out");
	return rst;
}

int memdump(const char *dump_filename)
{
	int i;
	FILE *dump = NULL;
	
	int error = 0;
	
	volatile uint32_t *p = map_base_mmio;
	uint32_t dump_word, mem_word;

	if (dump_filename == NULL) {
		for(i = 0; i < IDEAL_MEM_SIZE / sizeof(int); i++) {
			if(i % 4 == 0)
				log("0x%04x:", i << 2);
			
			log(" 0x%08x", map_base_mmio[i]);
			
			if(i % 4 == 3)
				log("\n");
		}

		log("\n");
		return 0;
	}

	log("Memory dump comparison:\n");
	
	dump = fopen(dump_filename, "r");
	if (dump == NULL)
		exit(-1);
	
	while (fscanf(dump, "%" PRIx32, &dump_word) == 1) {
		mem_word = *p;
		
		if (mem_word != dump_word) {
			log("mismatch at %p: expect %08" PRIx32 ", but get %08" PRIx32 "\n", p, dump_word, mem_word);
			error = 1;
		}
		p += 1;
	}
	return error;
}

void finish_map()
{
	map_base_mmio = NULL;
	map_base_mem = NULL;
	reset_base = NULL;

	munmap(map_base, MMAP_TOTAL_SIZE);
	map_base = NULL;

	munmap(reset_map_base, MMAP_TOTAL_SIZE);
	reset_map_base = NULL;

	close(fd);
}

int main(int argc, char *argv[]) {  
	int dump_result;
	
	const char *dump_filename = NULL;
	
	for (int i = 2; i < argc; i++) {
		const char *opt = argv[i];

		if (strcmp(opt, "verbose") == 0) {
			verbose = 1;
			
			char log_path[128];
			snprintf(log_path, sizeof(log_path), "%s.log", argv[1]);
			log_fp = fopen(log_path, "w");
		}
		else if (strcmp(opt, "--dump") == 0) {  // --dump <filename>
			dump_filename = argv[++i];
		}
		else {
			fprintf(stderr, "unexpected option: %s\n", opt);
			exit(-1);
		}
	}

	//set stdout with the property of no buffer
	setvbuf(stdout, NULL, _IONBF, 0);

	/* mapping the MIPS memory space into the address space of this program */
	init_map();

	/* loading binary executable file to ideal memory space */
	//argv[1] is the ELF file name running atop simple CPU
	loader(argv[1]);

	memdump(NULL);

	/* releasing MIPS CPU reset */
	reset(0);

	/* waiting for MIPS CPU to finish execution */
	log("Waiting for simple CPU to finish...\n");
	int result = wait_for_finish();
	log("Simple CPU execution is finished...\n");

	/* resetting MISP CPU */
	reset(1);

	/* dump all distributed memory */
	dump_result = memdump(dump_filename);

	result = dump_result || result;

	finish_map();
	
	if (result == 0)
		log("%s passed\n", argv[1]);
	
	else
		log("%s failed\n", argv[1]);

	if(verbose)
		fclose(log_fp);

	/**
	 * 0 - hit good trap
	 * 1 - hit bad trap
	 */
	return (result == 0) ? 0 : 1;
} 
