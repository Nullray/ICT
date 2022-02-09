//==========================================================
// custom CPU binary executable file loader
//
// Main Function:
// 1. Loads binary excutable file into distributed memory
// 2. Waits custom CPU for finishing program execution
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

#include <time.h>
#include <signal.h>
#include <errno.h>

#include <inttypes.h>

#include <assert.h>
#include <sys/time.h>
#include <sys/wait.h>

#include <termios.h>  // B115200

#define MMIO_BASE    0x82000000
#define ROLE_BASE    (MMIO_BASE + (ROLE_ID << 20)) 

#define MMIO_TOTAL_SIZE        (1 << 14)
#define CPU_RESET_REG_OFFSET   0x20000

#define PC_OFFSET      (0x1000 >> 2)
#define INST_OFFSET    (0x1008 >> 2)

#define MEM_BASE       0x4800000000ULL
#define MEM_ALIGN      0x80000000ULL
#define ROLE_MEM_BASE  (MEM_BASE + (ROLE_ID * MEM_ALIGN))

#define _HOST_TTY(id)  "/dev/ttyUL"#id
#define HOST_TTY(id)   _HOST_TTY(id)

#define MEM_TOTAL_SIZE		(1 << 30)
#define MEM_SHOW_SIZE		(1 << 14)
#define EXEC_FLAG_OFFSET        0x00000003

// The number of times to access 0xc to get the running result after a sleep
#define RETRY_TIMES 60
// The seconds between every two access to 0xc
#define SLEEP_TIME 1

static int UART_FD = 0;

void              *mem_map_base;
volatile uint32_t *mem_map_base_mmio;
volatile uint64_t *mem_map_base_mem;

void              *reg_map_base;
volatile uint32_t *reg_map_base_mmio;

int  fd;

static int verbose = 0;

static FILE *log_fp = NULL;
#define log(fmt, ...) do { if (verbose) fprintf(log_fp, fmt, ## __VA_ARGS__); } while(0)

#define mips_addr(p) (map_base + (uintptr_t)(p))

#define ALIGN_MASK_8_BYTES    0x07
#define ALIGN_MASK_4_BYTES    0x03

int set_interface_attribs (int fd, int speed, int parity);

void set_blocking(int fd, int should_block);

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

	// our MIPS CPU can only reset with PC = 0
	assert(elf->e_entry == 0);
	
	for(i = 0, ph = (void *)buf + elf->e_phoff; i < elf->e_phnum; i ++) {
		// scan the program header table, load each segment into memory
		if(ph[i].p_type == PT_LOAD) {
			uint64_t va = ph[i].p_vaddr;
			
			if(va >= MEM_TOTAL_SIZE)
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

				*(mem_map_base_mmio + (va >> 2)) = *(uint32_t *)buf_temp;

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

				*(mem_map_base_mem + (va >> 3)) = *(uint64_t *)buf_temp;

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

				*(mem_map_base_mmio + (va >> 2)) = *(uint32_t *)buf_temp;
				va += 4;
			}
			
			uint64_t rest = ph[i].p_memsz - ph[i].p_filesz;
			uint64_t zero_sz = 0;
			
			if (zero_sz < rest && (va & ALIGN_MASK_8_BYTES)) {
				*(mem_map_base_mmio + (va >> 2)) = 0;
				va += 4;
				zero_sz += 4;
			}
			while ((zero_sz + 8) <= rest) {
				*(mem_map_base_mem + (va >> 3)) = 0;
				va += 8;
				zero_sz += 8;
			}
			if (zero_sz < rest) {
				if ((zero_sz + 6) == rest) {
					*(mem_map_base_mmio + (va >> 2)) = 0;
					*((uint16_t *)mem_map_base_mmio + (va >> 1)) = 0;
					zero_sz += 6;
					va += 6;
				} else if ((zero_sz + 4) == rest) {
					*(mem_map_base_mmio + (va >> 2)) = 0;
					zero_sz += 4;
					va += 4;
				} else if ((zero_sz + 2) == rest) {
					*((uint16_t *)mem_map_base_mmio + (va >> 1)) = 0;
					zero_sz += 2;
					va += 2;
				} else {
					fprintf(stderr, "Invalid bss space size %d.", rest);
					exit(-1);
				}
			}
		}
	}
	fclose(fp);
}

void init_map()
{
	int i;

	fd = open("/dev/mem", O_RDWR | O_SYNC);  
	if (fd == -1) {  
		perror("init_map open failed:");
		exit(1);
	} 

	// Memory space mapping
	mem_map_base = mmap(NULL, MEM_TOTAL_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, 
			fd, ROLE_MEM_BASE);
	
	if (mem_map_base == NULL) {  
		perror("init_map mmap failed:");
		close(fd);
		exit(1);
	}  

	mem_map_base_mmio = (uint32_t *)mem_map_base;
	mem_map_base_mem = (uint64_t *)mem_map_base;

	//clear 16KB memory region
	for(i = 0; i < MEM_SHOW_SIZE / sizeof(int); i++)
		mem_map_base_mmio[i] = 0;
	
	// MMIO space mapping
	reg_map_base = mmap(NULL, MMIO_TOTAL_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, 
			fd, (ROLE_BASE + CPU_RESET_REG_OFFSET));

	if (reg_map_base == NULL) {  
		perror("init_map reg mmap failed:");
		close(fd);
		exit(1);
	}  

	reg_map_base_mmio = (uint32_t *)reg_map_base;
}

void reset(int val) {
	*(reg_map_base_mmio) = val;
}

void read_uart(time_t limit)
{
	const char * const magic = "benchmark finished\n";
	const char *p = magic;
	
	time_t prev = time(NULL);
	for (;;) {
		char ch;
		
		int n = read(UART_FD, &ch, sizeof(ch));
		if (n > 0) {
			putchar(ch);
			// Finish indicator
			if (ch == *p)
				p++;
			
			else if (p != magic)
				p = magic;  // reset

		} else {
			time_t curr = time(NULL);
			
			if (curr - prev > limit) {
				log("time up\n");
				break;
			}
		}
		
		if (*p == '\0')
			break;
	}
}

int wait_for_finish()
{
	struct timespec start = {}, end = {};
	clock_gettime(CLOCK_REALTIME, &start);
	
	uint32_t rst = -1;
	
	if (UART_FD > 0)
		read_uart(60); // 1 minute

	clock_gettime(CLOCK_REALTIME, &end);
	uint64_t slack = (end.tv_sec - start.tv_sec) * 1000000000ULL + (end.tv_nsec - start.tv_nsec);
	printf("time %.2fms\n", slack * 1.0 / 1000000);
	
	for (int i = 0; i < RETRY_TIMES; i++) {
		rst = *(mem_map_base_mmio + EXEC_FLAG_OFFSET);
		log("#%d access to result (= %u)\n", i + 1, rst);
		if (rst == 0 || rst == 1) {
			return rst;
		}

		printf("%s: current PC: %08x\n", __func__, *(reg_map_base_mmio + PC_OFFSET));
		printf("%s: current Inst: %08x\n", __func__, *(reg_map_base_mmio + INST_OFFSET));

		sleep(SLEEP_TIME);
	}
	
	log("custom cpu running time out");
	
	return rst;
}

int memdump(const char *dump_filename)
{
	int i;

	FILE *dump = NULL;
	
	int error = 0;
	
	volatile uint32_t *p = mem_map_base_mmio;
	uint32_t dump_word, mem_word;
	
	if (dump_filename == NULL) {
		for(i = 0; i < MEM_SHOW_SIZE / sizeof(int); i++) {
			if(i % 4 == 0) {
				log("0x%04x:", i << 2);
			}
			
			log(" 0x%08x", mem_map_base_mmio[i]);
			
			if(i % 4 == 3) {
				log("\n");
			}
		}

		log("\n");
		return 0;
	}

	log("Memory dump comparison:\n");
	
	dump = fopen(dump_filename, "r");
	if (dump == NULL)
		exit(-1);

	log("Base address is: %p\n", p);
	
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
	mem_map_base_mmio = NULL;
	mem_map_base_mem = NULL;
	munmap(mem_map_base, MEM_TOTAL_SIZE);
	mem_map_base = NULL;

	reg_map_base_mmio = NULL;
	munmap(reg_map_base, MMIO_TOTAL_SIZE);
	reg_map_base = NULL;

	close(fd);
}

int set_interface_attribs (int fd, int speed, int parity)
{
	struct termios tty;
	memset (&tty, 0, sizeof tty);
	if (tcgetattr (fd, &tty) != 0)
	{
		perror("tcgetattr");
		return -1;
	}

	cfsetospeed(&tty, speed);
	cfsetispeed(&tty, speed);

	tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8;     // 8-bit chars
	// disable IGNBRK for mismatched speed tests; otherwise receive break
	// as \000 chars
	tty.c_iflag &= ~IGNBRK;         // disable break processing
	tty.c_lflag = 0;                // no signaling chars, no echo,
	// no canonical processing
	tty.c_oflag = 0;                // no remapping, no delays
	tty.c_cc[VMIN]  = 0;            // read doesn't block
	tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

	tty.c_iflag &= ~(IXON | IXOFF | IXANY); // shut off xon/xoff ctrl

	tty.c_cflag |= (CLOCAL | CREAD);// ignore modem controls,
	// enable reading
	tty.c_cflag &= ~(PARENB | PARODD);      // shut off parity
	tty.c_cflag |= parity;
	tty.c_cflag &= ~CSTOPB;
	tty.c_cflag &= ~CRTSCTS;

	if (tcsetattr(fd, TCSANOW, &tty) != 0)
	{
		perror("tcsetattr");
		return -1;
	}
	return 0;
}

void set_blocking(int fd, int should_block)
{
	struct termios tty;
	memset (&tty, 0, sizeof tty);
	if (tcgetattr(fd, &tty) != 0)
	{
		perror("tggetattr");
		return;
	}

	tty.c_cc[VMIN]  = should_block ? 1 : 0;
	tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

	if (tcsetattr (fd, TCSANOW, &tty) != 0)
		perror("setting term attributes");
}

void init_uart_reader(const char *dev)
{
	UART_FD = open(dev, O_RDWR | O_NOCTTY | O_SYNC | O_NONBLOCK);
	if (UART_FD < 0) {
		fprintf(stderr, "opening %s: %s\n", dev, strerror(errno));
		exit(1);
	}
	
	set_interface_attribs(UART_FD, B115200, 0);  // set speed to 115,200 bps, 8n1 (no parity)
	set_blocking(fd, 0);                    // set non-blocking
}

int main(int argc, char *argv[])
{  
	//set stdout with the property of no buffer
	setvbuf(stdout, NULL, _IONBF, 0);
	
	const char *dump_filename = NULL;

	for (int i = 2; i < argc; i++) {
		const char *opt = argv[i];
		if (strcmp(opt, "verbose") == 0) {
			verbose = 1;
			char log_path[128];
			snprintf(log_path, sizeof(log_path), "%s.log", argv[1]);
			log_fp = fopen(log_path, "w");
		}
		
		else if (strcmp(opt, "uart") == 0) {
			init_uart_reader(HOST_TTY(ROLE_ID));
		}
		
		else if (strcmp(opt, "--dump") == 0) {  // --dump <filename>
			dump_filename = argv[++i];
		}
		
		else {
			fprintf(stderr, "unexpected option: %s\n", opt);
			exit(-1);
		}
	}

	/* mapping memory space of custom CPU into the address space of this program */
	init_map();
		
	/* resetting custom CPU */
	reset(1);

	/* loading target binary executable file to memory space of custom CPU */
	loader(argv[1]);

	memdump(NULL);

	/* releasing reset signal to custom CPU */
	reset(0);

	/* waiting for custom CPU to finish execution */
	log("Waiting for custom CPU to finish...\n");
	int result = wait_for_finish();
	log("custom CPU execution is finished...\n");

	/* resetting custom CPU */
	reset(1);

	/* dump all distributed memory */
	int dump_result = memdump(dump_filename);
	
	/* compare memory */
	result = dump_result || result;

	finish_map();
	
	if (result == 0)
		printf("%s passed\n", argv[1]);
	else
		printf("%s failed\n", argv[1]);

	if(verbose)
		fclose(log_fp);

	/**
	 * 0 - hit good trap
	 * 1 - hit bad trap
	 */
	return (result == 0) ? 0 : 1;
} 

