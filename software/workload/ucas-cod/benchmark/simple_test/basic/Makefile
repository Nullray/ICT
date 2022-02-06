
CC := $(CROSS_COMPILE)gcc
LD := $(CROSS_COMPILE)ld
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
LDFLAGS := -EL -N -e start -T user.ld

DIRS := bin elf obj disassembly sim
DIR_OBJS := $(foreach obj,$(DIRS),$(ARCH)/$(obj))

TARGET := memcpy
ELFS := $(addprefix $(ARCH)/elf/,$(TARGET))

all: $(ELFS)

$(ARCH)/elf/%: $(ARCH)/obj/%.o
	@mkdir -p $(DIR_OBJS)
	$(LD) $(LDFLAGS) -o $@ $^
	@cd $(ARCH) && \
		$(OBJDUMP) -j .text -DS ../$@ > disassembly/$(patsubst $(ARCH)/elf/%,%,$@).S && \
		$(OBJCOPY) -S -O binary -j .text -j .data ../$@ bin/$(patsubst $(ARCH)/elf/%,%,$@).bin
	@cd $(ARCH) && xxd -e -c 4 bin/$(patsubst $(ARCH)/elf/%,%,$@).bin | awk -F ":" '{print $$2}' | awk -F " " '{print $$1}' \
				> sim/$(patsubst $(ARCH)/elf/%,%,$@).mem

$(ARCH)/obj/%.o: $(ARCH)/%.S
	@mkdir -p $(DIR_OBJS)
	$(CC) -c $(CFLAGS) -o $@ $<

clean:
	@rm -rf $(DIR_OBJS)

