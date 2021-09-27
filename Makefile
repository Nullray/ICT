# TODO: Vivado IDE version and installed location
VIVADO_VERSION ?= 2019.1
VIVADO_TOOL_BASE ?= /opt/Xilinx_$(VIVADO_VERSION)

# Vivado and SDK tool executable binary location
VIVADO_TOOL_PATH := $(VIVADO_TOOL_BASE)/Vivado/$(VIVADO_VERSION)/bin
SDK_TOOL_PATH := $(VIVADO_TOOL_BASE)/SDK/$(VIVADO_VERSION)/bin

# Cross-compiler location
#=================================================
# aarch-linux-gnu- : used for compilation of uboot, Linux kernel, ATF and other drivers on ZynqMP
# aarch-none-gnu- : used for compilation of FSBL on ZynqMP
# arm-linux-gnueabihf- : used for compilation of uboot on Zynq
# arm-none-eabi- : used for compilation of FSBL on Zynq
# mb- (microblaze-xilinx-elf-) : used for compilation of PMU Firmware
#=================================================
zynqmp_LINUX_GCC_PATH := $(VIVADO_TOOL_BASE)/SDK/$(VIVADO_VERSION)/gnu/aarch64/lin/aarch64-linux/bin
zynqmp_ELF_GCC_PATH := $(VIVADO_TOOL_BASE)/SDK/$(VIVADO_VERSION)/gnu/aarch64/lin/aarch64-none/bin
zynq_LINUX_GCC_PATH := $(VIVADO_TOOL_BASE)/SDK/$(VIVADO_VERSION)/gnu/aarch32/lin/gcc-arm-linux-gnueabi/bin
zynq_ELF_GCC_PATH := $(VIVADO_TOOL_BASE)/SDK/$(VIVADO_VERSION)/gnu/aarch32/lin/gcc-arm-none-eabi/bin
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

PL_DT := $(abspath ./fpga/design/$(FPGA_PRJ)/dt/pl.dtsi)
PS_DT := $(abspath ./fpga/design/$(FPGA_PRJ)/dt/design.dtsi)
SYS_DT := $(abspath ./fpga/design/$(FPGA_PRJ)/dt/design_top.dtsi)

# Specify cross-compiler for target FPGA board
ARMv7_BOARDS := pynq serve_d

ifneq ($(findstring $(FPGA_BD),$(ARMv7_BOARDS)),)
FPGA_ARCH := zynq
FPGA_PROC := ps7_cortexa9_0
else
FPGA_ARCH := zynqmp
FPGA_PROC := psu_cortexa53_0
endif

BOOTBIN_DEP := fsbl
ifeq ($(FPGA_ARCH),zynqmp)
BOOTBIN_DEP += pmufw atf uboot
else
BOOTBIN_DEP += servefw
endif

obj-bootbin-clean-y := $(foreach obj,$(BOOTBIN_DEP),$(obj)_clean)
obj-bootbin-dist-y := $(foreach obj,$(BOOTBIN_DEP),$(obj)_distclean)

LINUX_GCC_PATH := $($(FPGA_ARCH)_LINUX_GCC_PATH)
ELF_GCC_PATH := $($(FPGA_ARCH)_ELF_GCC_PATH)

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
		PL_DT=$(PL_DT) PS_DT=$(PS_DT) SYS_DT=$(SYS_DT) $@

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

#==============================================
# QEMU Compilation (native compilation on aarch64)
#==============================================
qemu: FORCE
	$(MAKE) -C ./software $@

qemu_install: FORCE
	$(MAKE) -C ./software $@  

qemu_clean:
	$(MAKE) -C ./software $@

qemu_distclean:
	$(MAKE) -C ./software $@

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
bootbin: $(BOOTBIN_DEP) FORCE
	@echo "Generating BOOT.bin image..."
	@mkdir -p $(INSTALL_LOC)
	$(MAKE) -C ./bootstrap BOOT_GEN=$(BOOT_GEN_BIN) \
		WITH_BIT=$(WITH_BIT) BIT_LOC=$(FPGA_TARGET) \
		FPGA_ARCH=$(FPGA_ARCH) \
		WITH_TOS=$(WITH_TOS) O=$(INSTALL_LOC) boot_bin

bootbin_clean: $(obj-bootbin-clean-y)
	@rm -f $(INSTALL_LOC)/$(patsubst %.bootbin.clean,%,$@)/BOOT.bin

bootbin_distclean: $(obj-bootbin-dist-y)
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
		FPGA_ARCH=$(FPGA_ARCH) FPGA_PROC=$(FPGA_PROC) \
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
# Zynq baremetal firmware for SERVE
#==============================================
servefw: fsbl FORCE
	@mkdir -p fpga/design/serve/pdk/hw_plat/
	@cp hw_plat/$(FPGA_TARGET)/system.hdf fpga/design/serve/pdk/hw_plat/
	$(MAKE) -C fpga/design/serve/pdk \
		ARM_CC_PATH=$(ELF_GCC_PATH) SERVE=r \
		FPGA_ARCH=$(FPGA_ARCH) BOOTBIN_WITH_BIT=y arm_bare_metal

servefw_clean: FORCE
	$(MAKE) -C fpga/design/serve/pdk/bootstrap fsbl_distclean
	@rm -rf fpga/design/serve/pdk/hw_plat
	$(MAKE) -C fpga/design/serve/pdk SERVE=r \
		ARM_CC_PATH=$(ELF_GCC_PATH) arm_bare_metal_clean

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

#==========================================
# FPGA Design Flow
#==========================================
vivado_prj: FORCE
	@mkdir -p $(HW_PLATFORM)
	$(MAKE) -C ./fpga VIVADO=$(VIVADO_BIN) FPGA_BD=$(FPGA_BD) FPGA_PRJ=$(FPGA_PRJ) \
		FPGA_ACT=$(FPGA_ACT) FPGA_VAL="$(FPGA_VAL)" O=$(HW_PLATFORM) $@

