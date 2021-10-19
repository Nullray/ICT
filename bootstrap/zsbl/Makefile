ZSBL_BIN := zsbl.bin

CC := $(CROSS_COMPILE)gcc
AS := $(CROSS_COMPILE)as
OBJCOPY := $(CROSS_COMPILE)objcopy
OBJDUMP := $(CROSS_COMPILE)objdump

LN_FLAGS := -Tlinker.ld -static -nostdlib -Wl,--no-gc-sections
CC_FLAGS := -fPIC -DDRAM_BASE=$(DRAM_BASE) -DUART_BASE=$(UART_BASE) -I./include -I./ed25519 -I./sha3 -I./ -O2
ifeq ($(ZSBL_SANCTUM),y)
CC_FLAGS += -DWITH_SANCTUM
endif

OBJS := head.o print.o
ifeq ($(ZSBL_SANCTUM),y)
OBJS += bootloader.o
OBJS += $(patsubst %c,%o,$(wildcard ./ed25519/*.c))
OBJS += $(patsubst %c,%o,$(wildcard ./sha3/*.c))
endif

.PRECIOUS: %.o %.elf

zsbl: $(ZSBL_BIN)
	@echo "Finish zsbl compilation"

$(ZSBL_BIN): zsbl.img
	@dd if=$< of=$@ bs=2048 count=32

%.img: %.elf
	$(OBJCOPY) -O binary $< $@

%.elf: $(OBJS)
	$(CC) -o $@ $(LN_FLAGS) $(OBJS)

%.o: %.c
	$(CC) $(CC_FLAGS) -o $@ -c $<

%.o: %.S
	$(CC) $(CC_FLAGS) -o $@ -c $<

zsbl_clean zsbl_distclean:
	@rm -f *.img *.elf *.bin *.o

