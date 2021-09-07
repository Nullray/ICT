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

# Host machine to determine if it is cross compilation for Linux kernel
HOST := $(shell uname -m)

# Board and Chipset
FPGA_BD ?= nf
FPGA_PRJ := mpsoc
FPGA_TARGET := $(FPGA_PRJ)_$(FPGA_BD)

FPGA_DESIGN_DT_LOC := $(abspath ./fpga/design/$(FPGA_PRJ)/dt)

# Optional Trusted OS
TOS ?= 

# Linux kernel (i.e., Physical machine, Virtual machine, Dom0, DomU)
OS_KERN := phy_os virt

obj-sw-y := $(foreach obj,$(OS_KERN),$(obj).sw)
obj-sw-clean-y := $(foreach obj,$(OS_KERN),$(obj).sw.clean)
obj-sw-dist-y := $(foreach obj,$(OS_KERN),$(obj).sw.dist)

# Temporal directory to hold hardware design output files 
# (i.e., bitstream, hardware definition file (HDF))
HW_PLATFORM := $(shell pwd)/hw_plat/$(FPGA_TARGET)
BITSTREAM := $(HW_PLATFORM)/system.bit
SYS_HDF := $(HW_PLATFORM)/system.hdf

ifneq (${TOS},)
WITH_TOS := y
endif
WITH_TOS ?= n

WITH_BIT ?= n

# Temporal directory to save all image files for porting
INSTALL_LOC := $(shell pwd)/ready_for_download/$(FPGA_TARGET)

# FLAGS for sub-directory Makefile
ATF_COMPILE_FLAGS := COMPILER_PATH=$(LINUX_GCC_PATH) TOS=$(TOS)
UBOOT_COMPILE_FLAGS := COMPILER_PATH=$(LINUX_GCC_PATH) DTC_LOC=$(DTC_LOC)
XEN_COMPILE_FLAGS := COMPILER_PATH=$(LINUX_GCC_PATH) INSTALL_LOC=$(INSTALL_LOC)
ifneq ($(HOST),aarch64)
KERNEL_COMPILE_FLAGS := COMPILER_PATH=$(LINUX_GCC_PATH) INSTALL_LOC=$(INSTALL_LOC)
else
KERNEL_COMPILE_FLAGS := 
endif

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

#OpenBMC
OBMC_MACHINE := zcu102-zynqmp
OBMC_LOC := $(abspath ./software/arm-openbmc/tmp/deploy/images/$(OBMC_MACHINE))

# U-Boot mkimage
MKIMG_PATH := $(abspath ./software/arm-uboot/tools)

.PHONY: FORCE

sw: FORCE
	$(MAKE) bootbin
	$(foreach obj,$(obj-sw-y),\
		$(MAKE) $(patsubst %.sw,%.os,$(obj));)
	$(MAKE) rootfs

sw_clean:
	$(MAKE) bootbin_clean
	$(foreach obj,$(obj-sw-clean-y),\
		$(MAKE) $(patsubst %.sw.clean,%.os.clean,$(obj));)

sw_distclean:
	$(MAKE) bootbin_distclean
	$(foreach obj,$(obj-sw-dist-y),\
		$(MAKE) $(patsubst %.sw.dist,%.os.dist,$(obj));)
	@rm -rf software/arm-linux software/arm-uboot \
		software/arm-tee \
		bootstrap/.Xil

fpga: $(SYS_HDF) $(BITSTREAM)

fpga_clean:
	@rm -f $(SYS_HDF) $(BITSTREAM)

#==========================================
# iPXE cross compilation 
#==========================================
ipxe: FORCE
	$(MAKE) -C ./bootstrap \
		COMPILER_PATH=$(LINUX_GCC_PATH) \
		TARGET_IQN=$(IQN) \
		TFTP_SERVER=$(TFTP) \
		INSTALL_LOC=$(shell pwd)/ready_for_download $@

ipxe_clean:
	$(MAKE) -C ./bootstrap $@

ipxe_distclean:
	$(MAKE) -C ./bootstrap $@

#==========================================
# Generation of Device Tree Blob
#==========================================
dt: FORCE
	@echo "Compiling Device Tree..."
	$(MAKE) -C ./bootstrap DTC_LOC=$(DTC_LOC) \
		HSI=$(HSI_BIN) HDF_FILE=$(SYS_HDF) \
		FPGA_BD=$(FPGA_BD) O=$(INSTALL_LOC) \
		FPGA_DESIGN_DT_LOC=$(FPGA_DESIGN_DT_LOC) $@

dt_install: FORCE
	@cp $(INSTALL_LOC)/zynqmp.dtb \
		/mnt/phy_os/boot/efi/dtb/xilinx/
	
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

%.os.install: FORCE
	$(MAKE) -C ./software $(KERNEL_COMPILE_FLAGS) \
		OS=$(patsubst %.os.install,%,$@) linux_install

%.os.clean:
	$(MAKE) -C ./software $(KERNEL_COMPILE_FLAGS) \
		OS=$(patsubst %.os.clean,%,$@) linux_clean

%.os.dist:
	$(MAKE) -C ./software $(KERNEL_COMPILE_FLAGS) \
		OS=$(patsubst %.os.dist,%,$@) linux_distclean

#==========================================
# Compilation of XEN
#==========================================
xen: uboot FORCE
	@echo "Compiling ARM XEN..."
	$(MAKE) -C ./software $(XEN_COMPILE_FLAGS) $@

xen_clean: FORCE
	$(MAKE) -C ./software $@

xen_distclean: FORCE
	$(MAKE) -C ./software $@

#==========================================
# BOOT.bin generation
#==========================================
bootbin: atf fsbl pmufw uboot FORCE
	@echo "Generating BOOT.bin image..."
	@mkdir -p $(INSTALL_LOC)
	$(MAKE) -C ./bootstrap BOOT_GEN=$(BOOT_GEN_BIN) \
		WITH_BIT=$(WITH_BIT) BIT_LOC=$(FPGA_TARGET) \
		WITH_TOS=$(WITH_TOS) O=$(INSTALL_LOC) boot_bin

bootbin_clean: atf_clean fsbl_clean pmufw_clean uboot_clean
	@rm -f $(INSTALL_LOC)/$(patsubst %.bootbin.clean,%,$@)/BOOT.bin

bootbin_distclean: atf_distclean fsbl_distclean pmufw_distclean uboot_distclean
	$(MAKE) -C ./bootstrap boot_bin_distclean
	@rm -rf $(INSTALL_LOC)/$(patsubst %.bootbin.dist,%,$@)

#==========================================
# Compilation of BL31 (i.e., ARM Trusted Firmware (ATF)) 
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
		HSI=$(HSI_BIN) HDF_FILE=$(SYS_HDF) \
		FPGA_BD=$(FPGA_BD) $@

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
		HSI=$(HSI_BIN) HDF_FILE=$(SYS_HDF) $@ 

pmufw_bin: FORCE
	@echo "Generating PMU Firmware Binary..."
	$(MAKE) -C ./bootstrap COMPILER_PATH=$(MB_GCC_PATH) $@ 
	@cp ./bootstrap/pmufw/*.bin $(OBMC_LOC)

pmufw_clean:
	$(MAKE) -C ./bootstrap $@ 

pmufw_distclean:
	$(MAKE) -C ./bootstrap $@

#==========================================
# U-Boot Compilation
#==========================================
uboot: dt FORCE
	@echo "Compiling U-Boot..."
	$(MAKE) -C ./software $(UBOOT_COMPILE_FLAGS) \
		FPGA_PRJ=$(FPGA_PRJ) DTB_LOC=$(FPGA_TARGET) $@

uboot_clean: dt_clean
	$(MAKE) -C ./software $@

uboot_distclean: dt_distclean
	$(MAKE) -C ./software $@

#==============================================
# OpenBMC Compilation
#==============================================
openbmc: FORCE
	@mkdir -p $(INSTALL_LOC)
	$(MAKE) -C ./software OBMC_LOC=$(OBMC_LOC) \
		INSTALL_LOC=$(INSTALL_LOC) $@

openbmc_clean:
	$(MAKE) -C ./software $@

openbmc_distclean:
	$(MAKE) -C ./software $@

#==============================================
# Intermediate files between HW and SW design
#==============================================
$(SYS_HDF): FORCE
	$(MAKE) FPGA_ACT=prj_gen FPGA_BD=$(FPGA_BD) FPGA_PRJ=$(FPGA_PRJ) vivado_prj 

$(BITSTREAM): FORCE
	$(MAKE) FPGA_ACT=run_syn FPGA_BD=$(FPGA_BD) FPGA_PRJ=$(FPGA_PRJ) vivado_prj 
	$(MAKE) FPGA_ACT=bit_gen FPGA_BD=$(FPGA_BD) FPGA_PRJ=$(FPGA_PRJ) vivado_prj

#==========================================
# Specific FPGA project design
#==========================================
.PHONY: prj_hw prj_sw

prj_sw: FORCE
	$(MAKE) -C fpga/design/$(FPGA_PRJ) \
		FPGA_BD=$(FPGA_BD) PRJ_SW=$(PRJ_SW) $@

prj_sw_clean: FORCE
	$(MAKE) -C fpga/design/$(FPGA_PRJ) \
		FPGA_BD=$(FPGA_BD) PRJ_SW=$(PRJ_SW) $@

prj_sw_distclean: FORCE
	$(MAKE) -C fpga/design/$(FPGA_PRJ) \
		FPGA_BD=$(FPGA_BD) PRJ_SW=$(PRJ_SW) $@

prj_hw: FORCE
	$(MAKE) -C fpga/design/$(FPGA_PRJ) $@

prj_hw_clean:
	$(MAKE) -C fpga/design/$(FPGA_PRJ) $@

#==========================================
# FPGA Design Flow
#==========================================
vivado_prj: FORCE
	@mkdir -p $(HW_PLATFORM)
	$(MAKE) -C ./fpga VIVADO=$(VIVADO_BIN) FPGA_BD=$(FPGA_BD) FPGA_PRJ=$(FPGA_PRJ) \
		FPGA_ACT=$(FPGA_ACT) FPGA_VAL="$(FPGA_VAL)" O=$(HW_PLATFORM) $@

