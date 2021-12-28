host_dir = $(abspath .)
CXX =$(CROSS_COMPILE)g++
AR =$(CROSS_COMPILE)ar

DESIGN ?= FireSim
TARGET_CONFIG ?= FireSimRocketConfig

GENERATED_DIR = $(host_dir)/generated-src
simif_dir = $(host_dir)/simif
midas_h  = $(shell find $(simif_dir) -name "*.h")
midas_cc = $(shell find $(simif_dir) -name "*.cc")
long_name ?= firesim.firesim.FireSim.FireSimRocketConfig
TESTCHIPIP_CSRC_DIR = $(host_dir)/testchip/testchipip/csrc

# dromajo modifications
DROMAJO_DIR = $(host_dir)/dromajo-src
DROMAJO_LIB_NAME = dromajo_cosim
DROMAJO_LIB = $(DROMAJO_DIR)/lib$(DROMAJO_LIB_NAME).a

DROMAJO_H = $(GENERATED_DIR)/dromajo_params.h
DROMAJO_LONG_H = $(GENERATED_DIR)/$(long_name).dromajo_params.h

CHIPYARD_ROM = $(host_dir)/bootrom/bootrom.rv64.img
DROMAJO_ROM = $(GENERATED_DIR)/$(long_name).rom

DTS_FILE = $(GENERATED_DIR)/$(long_name).dts
DROMAJO_DTB = $(GENERATED_DIR)/$(long_name).dtb

#$(DROMAJO_LONG_H) $(DTS_FILE): $(VERILOG)

# Compile Driver
all: $(HEADER) $(DRIVER_CC) $(DRIVER_H) $(midas_cc) $(midas_h) $(runtime_conf)
	mkdir -p $(host_dir)/build
	mkdir -p $(host_dir)/elf
	cp $(HEADER) $(host_dir)/build/
	cp -f $(GENERATED_DIR)/$(CONF_NAME) $(host_dir)/build/runtime.conf
	$(MAKE) -C $(simif_dir) nf PLATFORM=nf DESIGN=$(DESIGN) \
        GEN_DIR=$(host_dir)/build OUT_DIR=$(host_dir)/build DRIVER="$(DRIVER_CC)" \
        TOP_DIR=$(host_dir)
	cp $(host_dir)/build/$(DESIGN)-nf $(host_dir)/build
$(DROMAJO_LIB):
	$(MAKE) -C $(DROMAJO_DIR)

$(DROMAJO_H): $(DROMAJO_LONG_H)
	rm -rf $(DROMAJO_H)
	ln -s $(DROMAJO_LONG_H) $(DROMAJO_H)

$(DROMAJO_DTB): $(DTS_FILE)
	dtc -I dts -O dtb -o $(DROMAJO_DTB) $(DTS_FILE)

$(DROMAJO_ROM): $(CHIPYARD_ROM)
	rm -rf $(DROMAJO_ROM)
	ln -s $(CHIPYARD_ROM) $(DROMAJO_ROM)

DROMAJO_REQS = $(DROMAJO_H) $(DROMAJO_ROM) $(DROMAJO_DTB)

firesim_lib_dir = $(host_dir)/firesim-lib
driver_dir = $(host_dir)/driver
fesvr_dir = $(host_dir)/fesvr
DRIVER_H = $(shell find $(driver_dir) -name "*.h") \
	$(shell find $(firesim_lib_dir) -name "*.h") \
	$(DROMAJO_REQS) \
	$(TESTCHIPIP_CSRC_DIR)/testchip_tsi.h

DRIVER_CC = $(wildcard $(addprefix $(driver_dir)/, $(addsuffix .cc, firesim/*))) \
	    $(wildcard $(addprefix $(firesim_lib_dir)/, $(addsuffix .cc, bridges/* fesvr/* )))  \
	    $(host_dir)/lib/libfesvr.a \
	    $(host_dir)/lib/libgmp.so \
	    $(DROMAJO_LIB) \
	    $(TESTCHIPIP_CSRC_DIR)/testchip_tsi.cc

HEADER  := $(GENERATED_DIR)/FireSim-const.h
CONF_NAME ?= runtime.conf

TARGET_CXX_FLAGS := -g -I$(TESTCHIPIP_CSRC_DIR) -I$(firesim_lib_dir) -I$(driver_dir)/firesim -I$(host_dir)/include -I$(firesim_lib_dir)/lib/boost -I$(DROMAJO_DIR) -I$(GENERATED_DIR) 
TARGET_LD_FLAGS := -L$(DROMAJO_DIR) -l$(DROMAJO_LIB_NAME) -L$(host_dir)/lib -lgmp -lfesvr

common_cxx_flags := $(TARGET_CXX_FLAGS) -Wno-unused-variable
common_ld_flags := $(TARGET_LD_FLAGS) -lrt

all: export CXXFLAGS := $(CXXFLAGS) $(common_cxx_flags) $(DRIVER_CXXOPTS)
# link libfesvr to make it easier to distribute drivers to nf instances
all: export LDFLAGS := $(LDFLAGS) $(common_ld_flags)


