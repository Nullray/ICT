# cross-compilers
CC := $(CROSS_COMPILE)gcc
OBJCOPY := $(CROSS_COMPILE)objcopy

CFLAGS := -mcmodel=medany -Wall -O2 -fno-common -fno-builtin-printf
LDFLAGS := -static -nostdlib -nostartfiles -lgcc

target := hello

CSRCS := $(wildcard *.c)
SRCS := $(wildcard *.S)

objs := $(foreach obj,$(SRCS),$(patsubst %.S,%,$(obj)).o)
objs += $(foreach obj,$(CSRCS),$(patsubst %.c,%,$(obj)).o)

all: $(target)
	@mkdir -p bin
	$(OBJCOPY) -O binary elf/$^ bin/$(target).bin	

$(target): $(objs)
	@mkdir -p elf
	$(CC) -T link.ld $(LDFLAGS) $^ -o elf/$@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	@rm -rf *.o bin/ elf/
