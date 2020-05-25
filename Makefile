# TODO: Vivado IDE version and installed location
VIVADO_VERSION ?= 2019.1
VIVADO_TOOL_BASE ?= /opt/Xilinx_$(VIVADO_VERSION)

# Vivado and SDK tool executable binary location
VIVADO_TOOL_PATH := $(VIVADO_TOOL_BASE)/Vivado/$(VIVADO_VERSION)/bin
SDK_TOOL_PATH := $(VIVADO_TOOL_BASE)/SDK/$(VIVADO_VERSION)/bin

# Cross-compiler location
#=================================================
# aarch-linux-gnu- : used for compilation of uboot, Linux kernel, ATF and other drivers
# aarch-none-gnu- : used for compilation of FSBL
# mb- (microblaze-xilinx-elf-) : used for compilation of PMU Firmware
#=================================================
LINUX_GCC_PATH := $(VIVADO_TOOL_BASE)/SDK/$(VIVADO_VERSION)/gnu/aarch64/lin/aarch64-linux/bin
ELF_GCC_PATH := $(VIVADO_TOOL_BASE)/SDK/$(VIVADO_VERSION)/gnu/aarch64/lin/aarch64-none/bin
MB_GCC_PATH := $(VIVADO_TOOL_BASE)/SDK/$(VIVADO_VERSION)/gnu/microblaze/lin/bin

# Leveraged Vivado tools
VIVADO_BIN := $(VIVADO_TOOL_PATH)/vivado
HSI_BIN := $(SDK_TOOL_PATH)/hsi
BOOT_GEN_BIN := $(SDK_TOOL_PATH)/bootgen

# Optional Trusted OS
TOS ?= 

# Linux kernel (i.e., Physical machine, Dom0, DomU)
OS_KERN := phy_os

obj-sw-y := $(foreach obj,$(OS_KERN),$(obj).sw)
obj-sw-clean-y := $(foreach obj,$(OS_KERN),$(obj).sw.clean)
obj-sw-dist-y := $(foreach obj,$(OS_KERN),$(obj).sw.dist)

# TODO: Change target file system
phy_os-fs-obj := aarch64-debian-10.tar.gz
phy_os-fs-path := rootfs/aarch64/debian/release

# Temporal directory to hold hardware design output files 
# (i.e., bitstream, hardware definition file (HDF))
HW_PLATFORM := $(shell pwd)/hw_plat
BITSTREAM := $(HW_PLATFORM)/system.bit
SYS_HDF := $(HW_PLATFORM)/system.hdf

ifneq (${TOS},)
WITH_TOS := y
endif
WITH_TOS ?= n

WITH_BIT ?= n

# Temporal directory to save all image files for porting
INSTALL_LOC := $(shell pwd)/ready_for_download

# FLAGS for sub-directory Makefile
ATF_COMPILE_FLAGS := COMPILER_PATH=$(LINUX_GCC_PATH) TOS=$(TOS)
UBOOT_COMPILE_FLAGS := COMPILER_PATH=$(LINUX_GCC_PATH) DTC_LOC=$(DTC_LOC)
KERNEL_COMPILE_FLAGS := COMPILER_PATH=$(LINUX_GCC_PATH) INSTALL_LOC=$(INSTALL_LOC)

# Device Tree Compiler (DTC)
DTC_LOC := /opt/dtc

# FPGA_ACT list
#==========================================
# prj_gen: Creating Vivado project and generating hardware 
#          definition file (HDF)
# run_syn: Synthesizing design
# bit_gen: Generating bitstream file (.bit) via automatically 
#          launching placement and routing
# dcp_chk: Opening a checkpoint (.dcp) file generated in a certain step 
#          of synthesis, placement and routing. 
#          You can optionally setup hardware debug cores when opening 
#          the synth.dcp
#==========================================
# Default Vivado GUI launching flags if not specified in command line
FPGA_ACT ?= 
FPGA_VAL ?= 

.PHONY: FORCE

sw: $(obj-sw-y)

sw_clean: $(obj-sw-clean-y)

sw_distclean: $(obj-sw-dist-y)
	@rm -rf software/arm-linux software/arm-uboot \
		bootstrap/.Xil

fpga: $(SYS_HDF) $(BITSTREAM)

fpga_clean:
	@rm -f $(SYS_HDF) $(BITSTREAM)

fpga_distclean:
	$(MAKE) -C ./fpga vivado_prj_clean

%.sw: FORCE
ifneq ($(patsubst %.sw,%,$@),domU)
	$(MAKE) $(patsubst %.sw,%.uboot,$@)
	$(MAKE) $(patsubst %.sw,%.bootbin,$@)
endif
ifeq ($(patsubst %.sw,%,$@),dom0)
	$(MAKE) xen
endif
	$(MAKE) $(patsubst %.sw,%.os,$@)
	$(MAKE) $(patsubst %.sw,%.fs,$@)
	@echo "All required images of $(patsubst %.sw,%,$@) are generated"

%.sw.clean:
ifneq ($(patsubst %.sw.clean,%,$@),domU)
	$(MAKE) $(patsubst %.sw.clean,%.bootbin.clean,$@)
	$(MAKE) $(patsubst %.sw.clean,%.uboot.clean,$@)
endif
ifeq ($(patsubst %.sw.clean,%,$@),dom0)
	$(MAKE) xen_clean
endif
	$(MAKE) $(patsubst %.sw.clean,%.os.clean,$@)

%.sw.dist:
ifneq ($(patsubst %.sw.dist,%,$@),domU)
	$(MAKE) $(patsubst %.sw.dist,%.bootbin.dist,$@)
	$(MAKE) $(patsubst %.sw.dist,%.uboot.dist,$@)
endif
ifeq ($(patsubst %.sw.dist,%,$@),dom0)
	$(MAKE) xen_distclean
endif
	$(MAKE) $(patsubst %.sw.dist,%.os.dist,$@)

#==========================================
# U-Boot Compilation
#==========================================
%.uboot: dt FORCE
	@echo "Compiling U-Boot..."
	$(MAKE) -C ./software $(UBOOT_COMPILE_FLAGS) \
		OS=$(patsubst %.uboot,%,$@) uboot

%.uboot.clean: dt_clean
	$(MAKE) -C ./software \
		OS=$(patsubst %.uboot.clean,%,$@) uboot_clean

%.uboot.dist: dt_distclean
	$(MAKE) -C ./software \
		OS=$(patsubst %.uboot.dist,%,$@) uboot_distclean

#==========================================
# Generation of Device Tree Blob
#==========================================
dt: $(SYS_HDF) FORCE
	@echo "Compiling Device Tree..."
	$(MAKE) -C ./bootstrap DTC_LOC=$(DTC_LOC) \
		HSI=$(HSI_BIN) O=$(INSTALL_LOC) $@

dt_clean:
	$(MAKE) -C ./bootstrap O=$(INSTALL_LOC) $@

dt_distclean:
	$(MAKE) -C ./bootstrap O=$(INSTALL_LOC) $@

#==========================================
# Linux kernel compilation 
#==========================================
%.os: FORCE
	@mkdir -p $(INSTALL_LOC)
	$(MAKE) -C ./software $(KERNEL_COMPILE_FLAGS) \
		OS=$(patsubst %.os,%,$@) linux

%.os.clean:
	$(MAKE) -C ./software $(KERNEL_COMPILE_FLAGS) \
		OS=$(patsubst %.os.clean,%,$@) linux_clean

%.os.dist:
	$(MAKE) -C ./software $(KERNEL_COMPILE_FLAGS) \
		OS=$(patsubst %.os.dist,%,$@) linux_distclean

#==========================================
# BOOT.bin generation
#==========================================
%.bootbin: atf fsbl pmufw FORCE
	@echo "Generating BOOT.bin image..."
	@mkdir -p $(INSTALL_LOC)/$(patsubst %.bootbin,%,$@)
	$(MAKE) -C ./bootstrap BOOT_GEN=$(BOOT_GEN_BIN) \
		WITH_BIT=$(WITH_BIT) OS=$(patsubst %.bootbin,%,$@) \
		WITH_TOS=$(WITH_TOS) O=$(INSTALL_LOC) boot_bin

%.bootbin.clean: atf_clean fsbl_clean pmufw_clean
	@rm -f $(INSTALL_LOC)/$(patsubst %.bootbin.clean,%,$@)/BOOT.bin

%.bootbin.dist: atf_distclean fsbl_distclean pmufw_distclean
	$(MAKE) -C ./bootstrap boot_bin_distclean
	@rm -rf $(INSTALL_LOC)/$(patsubst %.bootbin.dist,%,$@)

#==========================================
# Generation of BL31 (i.e., ARM Trusted Firmware (ATF)) 
# and optional BL32 Trusted OS (e.g., OP-TEE) 
#==========================================
atf: FORCE
	@echo "Compiling ARM Trusted Firmware..."
	$(MAKE) -C ./software $(ATF_COMPILE_FLAGS) \
		TOS=$(TOS) $@

atf_clean: FORCE
	$(MAKE) -C ./software TOS=$(TOS) $@

atf_distclean: FORCE
	$(MAKE) -C ./software TOS=$(TOS) $@

#==========================================
# Generation of Xilinx FSBL (BL2)
#==========================================
fsbl: FORCE
	@echo "Compiling FSBL..."
	$(MAKE) -C ./bootstrap COMPILER_PATH=$(ELF_GCC_PATH) \
		HSI=$(HSI_BIN) $@ 

fsbl_clean:
	$(MAKE) -C ./bootstrap $@

fsbl_distclean:
	$(MAKE) -C ./bootstrap $@

#==========================================
# Generation of PMU Firmware (PMUFW)
#==========================================
pmufw: FORCE
	@echo "Compiling PMU Firmware..."
	$(MAKE) -C ./bootstrap COMPILER_PATH=$(MB_GCC_PATH) \
		HSI=$(HSI_BIN) $@ 

pmufw_clean:
	$(MAKE) -C ./bootstrap $@ 

pmufw_distclean:
	$(MAKE) -C ./bootstrap $@

#==============================================
# File system
#==============================================
FTP_ROOT := 172.16.128.201
FTP_USER := ftpuser
FTP_PASSWD := 123456

%.fs: FORCE
	@mkdir -p $(INSTALL_LOC)/$(patsubst %.fs,%,$@)
	@cd $(INSTALL_LOC)/$(patsubst %.fs,%,$@) && \
		wget ftp://$(FTP_ROOT)/$($(patsubst %.fs,%,$@)-fs-path)/$($(patsubst %.fs,%,$@)-fs-obj) \
		--ftp-user=$(FTP_USER) --ftp-password=$(FTP_PASSWD)

#==============================================
# Intermediate files between HW and SW design
#==============================================
$(SYS_HDF): FORCE
	$(MAKE) FPGA_ACT=prj_gen vivado_prj 

$(BITSTREAM): FORCE
	$(MAKE) FPGA_ACT=run_syn vivado_prj 
	$(MAKE) FPGA_ACT=bit_gen vivado_prj

#==========================================
# FPGA Design Flow
#==========================================
vivado_prj: FORCE
	@mkdir -p $(HW_PLATFORM)
	$(MAKE) -C ./fpga VIVADO=$(VIVADO_BIN) FPGA_ACT=$(FPGA_ACT) FPGA_VAL="$(FPGA_VAL)" O=$(HW_PLATFORM) $@

