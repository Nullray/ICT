# cross-compilers
CC := $(CROSS_COMPILE)gcc

target := rv_bin_loader 

CSRCS := $(wildcard *.c)

all:
	@mkdir -p elf
	$(CC) $(CFLAGS) $(CSRCS) -o elf/$(target)

clean:
	@rm -rf *.o elf/
