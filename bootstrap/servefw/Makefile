CURRENT_DIR = $(shell pwd)
FSBL_LOC := $(CURRENT_DIR)/../fsbl

CC := $(CROSS_COMPILE)gcc

CC_FLAGS := -MMD -MP    
LN_FLAGS := -Wl,--gc-sections
ifeq ($(FPGA_ARCH),zynq)
CC_FLAGS += -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard 
LN_FLAGS += -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -Wl,-build-id=none -specs=$(FSBL_LOC)/Xilinx.spec \
			-Wl,--start-group,-lxil,-lxilffs,-lgcc,-lc,-lrsa,--end-group 
else
LN_FLAGS += -Wl,--start-group,-lxil,-lxilffs,-lgcc,-lc,--end-group 
endif
CFLAGS := 

c_SOURCES := $(wildcard *.c)
INCLUDES := $(wildcard *.h)
OBJS := $(patsubst %.c, %.o, $(c_SOURCES))
LSCRIPT := -Tlscript_$(FPGA_ARCH).ld

DEPFILES := $(patsubst %.o, %.d, $(OBJS))
EXEC := executable.elf

INCLUDEPATH := -I$(FSBL_LOC)/$(FPGA_ARCH)_fsbl_bsp/$(FPGA_PROC)/include -I.
LIBPATH := -L$(FSBL_LOC)/$(FPGA_ARCH)_fsbl_bsp/$(FPGA_PROC)/lib -L./

ifeq ($(WITH_BIT),y)
CC_FLAGS += -DUSE_BIT
endif

ifeq ($(FPGA_ARCH),zynqmp)
CC_FLAGS += -DUSE_ZYNQMP
endif

all: $(EXEC)

$(EXEC): $(OBJS) $(INCLUDES)
	$(CC) -o $@ $(OBJS) $(CC_FLAGS) $(CFLAGS) $(LN_FLAGS) $(LIBPATH) $(LSCRIPT)

%.o:%.c
	$(CC) $(CC_FLAGS) $(CFLAGS) -c $< -o $@ $(INCLUDEPATH)

clean:
	rm -rf $(OBJS) $(EXEC) *.o *.d

-include $(DEPFILES)

