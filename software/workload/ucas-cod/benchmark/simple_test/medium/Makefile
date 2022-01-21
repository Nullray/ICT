
CC      := $(CROSS_COMPILE)gcc
AS      := $(CROSS_COMPILE)as
LD      := $(CROSS_COMPILE)ld
OBJDUMP := $(CROSS_COMPILE)objdump
OBJCOPY := $(CROSS_COMPILE)objcopy

ifeq ($(ARCH),mips)
CFLAGS := -fno-pic -static -fno-strict-aliasing -fno-delayed-branch -fno-builtin \
	  -fno-stack-protector -mno-check-zero-division \
	  -Wall -Werror -mno-imadd -mno-mad -EL -mips32 -G0 -I include
endif

ifeq ($(ARCH),riscv32)
CFLAGS = -fno-pic -static -fno-strict-aliasing -fno-delayed-branch -fno-builtin \
	 -fno-stack-protector -Wall -Werror -march=rv32i -O0 -I include
endif
CFLAGS += -I $(ARCH)/common
ASFLAGS := -EL
LDFLAGS := -EL -N -e start -T user.ld

DIRS := bin elf obj disassembly
DIR_OBJS := $(foreach obj,$(DIRS),$(ARCH)/$(obj))

TARGET := $(patsubst src/%.c,%,$(wildcard src/*.c))
ELFS := $(addprefix $(ARCH)/elf/,$(TARGET))

NO_OPT_TARGET  := if-else min3 select-sort max
NO_OPT_OBJ_LOC := $(addprefix $(ARCH)/obj/, $(NO_OPT_TARGET))
NO_OPT_OBJ     := $(addsuffix .o, $(NO_OPT_OBJ_LOC))

all: $(ELFS)

$(ARCH)/elf/%: $(ARCH)/common/start.o $(ARCH)/obj/%.o
	@mkdir -p $(DIR_OBJS)
	$(LD) $(LDFLAGS) -o $@ $^
	@cd $(ARCH) && \
		$(OBJDUMP) -DS ../$@ > disassembly/$(patsubst $(ARCH)/elf/%,%,$@).S && \
		$(OBJCOPY) -S -O binary \
		    -j .text -j .text.startup -j .MIPS.abiflags \
		    -j .data -j .rodata \
		    -j .bss --set-section-flags .bss=alloc,contents \
		    -j .sbss --set-section-flags .sbss=alloc,contents \
		    -j .scommon --set-section-flags .scommon=alloc,contents \
		    ../$@ bin/$(patsubst $(ARCH)/elf/%,%,$@).bin

$(NO_OPT_OBJ): $(ARCH)/obj/%.o: src/%.c
	@mkdir -p $(DIR_OBJS)
	$(CC) -c $(CFLAGS) -o $@ $<

$(ARCH)/obj/%.o: src/%.c
	@mkdir -p $(DIR_OBJS)
	$(CC) -c $(CFLAGS) -O2 -o $@ $<

$(ARCH)/common/start.o: $(ARCH)/common/start.S 
	$(CC) -c $(CFLAGS) -o $@ $<

clean:
	rm -rf $(DIR_OBJS) $(ARCH)/common/start.o

