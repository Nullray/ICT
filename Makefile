# Xilinx Vivado toolset and open-source device tree compiler
include build_scripts/toolset.mk

# Specified FPGA board, chipset and project
include build_scripts/fpga_config.mk

# Target ISA for compilation of bootstrap, firmware and system software
# Default value is empty, which means ISA is specified by FPGA chip
ARCH ?= 

# target compiler setup
include build_scripts/compiler.mk

# Temporal directory to hold hardware design output files 
# (i.e., bitstream, hardware definition file (HDF))
HW_PLATFORM := $(shell pwd)/hw_plat/$(FPGA_TARGET)
BITSTREAM := $(HW_PLATFORM)/system.bit
SYS_HDF := $(HW_PLATFORM)/system.hdf

# Temporal directory to save all image files for porting
INSTALL_LOC := $(shell pwd)/ready_for_download/$(FPGA_TARGET)

# Optional Trusted OS
TOS ?= 

# BOOT.bin generation flags
ifneq ($(TOS),)
WITH_TOS := y
endif
WITH_TOS ?= n

WITH_BIT ?= n

.PHONY: FORCE

# bootstrap compilation
ifneq ($(wildcard fpga/design/$(FPGA_PRJ)/$(PRJ_BS_MK)),)
include fpga/design/$(FPGA_PRJ)/$(PRJ_BS_MK)
endif
include build_scripts/bootstrap.mk

# software compilation
ifneq ($(wildcard fpga/design/$(FPGA_PRJ)/$(PRJ_SW_MK)),)
include fpga/design/$(FPGA_PRJ)/$(PRJ_SW_MK)
endif
include build_scripts/software.mk

# fpga design flow
include build_scripts/fpga.mk

# bootbin generation for various architectures
include build_scripts/bootbin.mk

sw: FORCE
	$(MAKE) bootbin
	$(MAKE) phy_os.os

sw_clean:
	$(MAKE) bootbin_clean
	$(MAKE) phy_os.os.clean

sw_distclean:
	$(MAKE) bootbin_distclean
	$(MAKE) phy_os.os.dist
	@rm -rf software/arm-linux software/arm-uboot \
		software/arm-tee bootstrap/.Xil

#==========================================
# Specific FPGA project design
#==========================================
.PHONY: prj_hw prj_sw

prj_sw: FORCE
	$(MAKE) -C fpga/design/$(FPGA_PRJ) \
		FPGA_BD=$(FPGA_BD) \
		PRJ_TARGET=$(PRJ_TARGET) PRJ_SW=$(PRJ_SW) $@

prj_sw_clean: FORCE
	$(MAKE) -C fpga/design/$(FPGA_PRJ) \
		FPGA_BD=$(FPGA_BD) \
		PRJ_TARGET=$(PRJ_TARGET) PRJ_SW=$(PRJ_SW) $@

prj_sw_distclean: FORCE
	$(MAKE) -C fpga/design/$(FPGA_PRJ) \
		FPGA_BD=$(FPGA_BD) \
		PRJ_TARGET=$(PRJ_TARGET) PRJ_SW=$(PRJ_SW) $@

prj_hw: FORCE
	$(MAKE) -C fpga/design/$(FPGA_PRJ) $@

prj_hw_clean:
	$(MAKE) -C fpga/design/$(FPGA_PRJ) $@

