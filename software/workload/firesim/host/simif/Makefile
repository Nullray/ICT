midas_dir = $(abspath .)
util_dir = $(midas_dir)/utils
bridge_dir = $(midas_dir)/bridges
########################################################################
# Parameters:
# 1) PLATFORM: FPGA platform board(by default zynq)
# 2) DESIGN: Target design of midas
# 3) GEN_DIR: Directory for generated source code
# 4) OUT_DIR: Directory for binary files (by default GEN_DIR)
# 5) DRIVER: software driver written by user
# 6) CLOCK_PERIOD(optional): clock period of tests
# 7) VERILATOR_FLAGS(optional): set of verilator flags to add
########################################################################
ifeq ($(strip $(DESIGN)),)
$(error Define DESIGN, the target design)
endif
ifeq ($(strip $(GEN_DIR)),)
$(error Define GEN_DIR, where all midas generated code reside)
endif
ifeq ($(strip $(TOP_DIR)),)
$(error Define TOP_DIR, the top of the host directory)
endif
ifeq ($(strip $(DRIVER)),)
$(error Define DRIVER, the source code of the simulation driver)
endif

PLATFORM ?= zynq
OUT_DIR ?= $(GEN_DIR)
CLOCK_PERIOD ?= 1.0
CXX:= $(CROSS_COMPILE)g++
$(info platform: $(PLATFORM))
$(info target design: $(DESIGN))
$(info generated source directory: $(GEN_DIR))
$(info output directory: $(OUT_DIR))
$(info driver source files: $(DRIVER))
$(info clock period: $(CLOCK_PERIOD))
$(info CXX: $(CXX))
shim := FPGATop

testchip_dir=$(TOP_DIR)/testchip
testchip_csrc_dir=$(TOP_DIR)/testchip/testchipip/csrc
dramsim_dir=$(TOP_DIR)/DRAMSim2

override CXXFLAGS := $(CXXFLAGS) -std=c++11 -Wall -I$(dramsim_dir) -I$(testchip_csrc_dir)

#include $(util_dir)/utils.mk

#$(OUT_DIR)/dramsim2_ini: $(testchip_dir)/dramsim2_ini
#	ln -sf $< $@

$(OUT_DIR)/$(DESIGN).chain:
	$(if $(wildcard $(GEN_DIR)/$(DESIGN).chain),cp $(GEN_DIR)/$(DESIGN).chain $@,)

override CXXFLAGS += -I$(midas_dir) -I$(util_dir)
# The trailing whitespace is important for some reason...
override LDFLAGS := $(LDFLAGS) -L$(GEN_DIR) -lstdc++ -lpthread
# -lgmp  
# -lmidas

design_v  := $(GEN_DIR)/$(shim).v
design_h  := $(GEN_DIR)/$(DESIGN)-const.h
design_vh := $(GEN_DIR)/$(DESIGN)-const.vh
driver_h = $(foreach t, $(DRIVER), $(wildcard $(dir $(t))/*.h))
bridge_h := $(wildcard $(bridge_dir)/*.h)
bridge_cc := $(wildcard $(bridge_dir)/*.cc)
bridge_o := $(patsubst $(bridge_dir)/%.cc, $(GEN_DIR)/%.o, $(bridge_cc))
$(bridge_o): $(GEN_DIR)/%.o: $(bridge_dir)/%.cc $(design_h) $(bridge_h)
	$(CXX) $(CXXFLAGS) -c -o $@ $< -include $(word 2, $^)

platform_files := simif simif_$(PLATFORM)
platform_h := $(addprefix $(midas_dir)/, $(addsuffix .h, $(platform_files)))
platform_cc := $(addprefix $(midas_dir)/, $(addsuffix .cc, $(platform_files)))
platform_o := $(addprefix $(GEN_DIR)/, $(addsuffix .o, $(platform_files)))

$(platform_o): $(GEN_DIR)/%.o: $(midas_dir)/%.cc $(design_h) $(platform_h)
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c -o $@ $< -include $(word 2, $^)
	@echo $(CXXFLAGS)
$(OUT_DIR)/$(DESIGN)-$(PLATFORM): $(design_h) $(lib) $(DRIVER) $(driver_h) $(platform_o) $(bridge_o)
	mkdir -p $(OUT_DIR)
	$(CXX) $(CXXFLAGS) -include $< \
	-o $@ $(DRIVER) $(lib_o) $(platform_o) $(bridge_o) $(LDFLAGS)
$(PLATFORM): $(OUT_DIR)/$(DESIGN)-$(PLATFORM) $(OUT_DIR)/$(DESIGN).chain
