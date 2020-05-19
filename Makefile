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

# TODO: Optional Trusted OS
TOS := 
BL32 := $(TOS)
obj-tos-y := $(foreach obj,$(TOS),$(obj).tos)
obj-tos-clean-y := $(foreach obj,$(TOS),$(obj).tos.clean)
obj-tos-dist-y := $(foreach obj,$(TOS),$(obj).tos.dist)

# TODO: Linux kernel (i.e., Physical machine, Dom0, DomU)
# Default value is phys_os if not specified in command line
OS_KERN := phys_os
obj-os-y := $(foreach obj,$(OS_KERN),$(obj).os)
obj-os-clean-y := $(foreach obj,$(OS_KERN),$(obj).os.clean)
obj-os-dist-y := $(foreach obj,$(OS_KERN),$(obj).os.dist)

obj-dt-y := $(foreach obj,$(OS_KERN),$(obj).dt)
obj-dt-clean-y := $(foreach obj,$(OS_KERN),$(obj).dt.clean)
obj-dt-dist-y := $(foreach obj,$(OS_KERN),$(obj).dt.dist)

# Temporal directory to hold hardware design output files 
# (i.e., bitstream, hardware definition file (HDF))
HW_PLATFORM := $(shell pwd)/hw_plat
BITSTREAM := $(HW_PLATFORM)/system.bit
HW_DESIGN_HDF := $(HW_PLATFORM)/system.hdf

HW_PLAT_TEMP := $(shell pwd)/bootstrap/hw_plat

# Object files to generate BOOT.bin
BL2_BIN := ./bootstrap/fsbl/bl2.elf
PMU_FW := ./bootstrap/pmufw/pmufw.elf
BL31_BIN := ./software/arm-atf/bl31.elf
BL33_BIN := ./software/arm-uboot/u-boot.elf

BOOT_BIN_OBJS := $(BL31_BIN) $(BL33_BIN) $(BL2_BIN) $(PMU_FW)

ifneq (${TOS},)
BOOTBIN_WITH_TOS := y
endif
BOOTBIN_WITH_TOS ?= n

BOOTBIN_WITH_BIT ?= n
ifeq (${BOOTBIN_WITH_BIT},y)
BOOT_BIN_OBJS += $(BITSTREAM)
endif

# Temporal directory to save all image files for porting
INSTALL_LOC := $(shell pwd)/ready_for_download

# FLAGS for sub-directory Makefile
ATF_COMPILE_FLAGS := COMPILER_PATH=$(LINUX_GCC_PATH) TOS=$(TOS) INSTALL_LOC=$(INSTALL_LOC)
UBOOT_COMPILE_FLAGS := COMPILER_PATH=$(LINUX_GCC_PATH) DTC_LOC=$(DTC_LOC) INSTALL_LOC=$(INSTALL_LOC)
KERNEL_COMPILE_FLAGS := COMPILER_PATH=$(LINUX_GCC_PATH) INSTALL_LOC=$(INSTALL_LOC)

# Device Tree Compiler (DTC)
DTC_LOC := /opt/dtc

# HW_ACT list
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
HW_ACT ?= none
HW_VAL ?= none

.PHONY: FORCE

#==========================================
# Generation of BL31 (i.e., ARM Trusted Firmware (ATF)) 
# and optional BL32 Trusted OS (e.g., OP-TEE) 
#==========================================
atf $(BL31_BIN): $(obj-tos-y) FORCE
	@echo "Compiling ARM Trusted Firmware..."
	$(MAKE) -C ./software $(ATF_COMPILE_FLAGS) atf

atf_clean: $(obj-tos-clean-y) FORCE
	$(MAKE) -C ./software $(ATF_COMPILE_FLAGS) $@

atf_distclean: $(obj-tos-dist-y) FORCE
	$(MAKE) -C ./software $(ATF_COMPILE_FLAGS) $@

#==========================================
# Generation of BL33 image, including U-Boot,
# Linux kernel for virtual and non-virtual 
# environment, and optional Xen hypervisor
#==========================================
uboot $(BL33_BIN): phy_os.dt FORCE
	@echo "Compiling U-Boot..."
	$(MAKE) -C ./software $(UBOOT_COMPILE_FLAGS) uboot

uboot_clean:
	$(MAKE) -C ./software $(UBOOT_COMPILE_FLAGS) $@

uboot_distclean:
	$(MAKE) -C ./software $(UBOOT_COMPILE_FLAGS) $@

%.os: FORCE
	@mkdir -p $(INSTALL_LOC)
	$(MAKE) -C ./software $(KERNEL_COMPILE_FLAGS) \
		OS=$(patsubst %.os,%,$@) linux

%.os.clean: FORCE
	$(MAKE) -C ./software \
		OS=$(patsubst %.os.clean,%,$@) linux_clean 
	@rm -f $(INSTALL_LOC)/$(patsubst %.os.clean,%,$@)/Image 

%.os.dist: FORCE
	$(MAKE) -C ./software \
		OS=$(patsubst %.os.dist,%,$@) linux_distclean

#==========================================
# Generation of physical os Device Tree Blob
#==========================================
phy_os.dt: FORCE
	@echo "Compiling Device Tree..."
	$(MAKE) -C ./bootstrap DTC_LOC=$(DTC_LOC) \
		HSI=$(HSI_BIN) O=$(INSTALL_LOC) dt

phy_os.dt.clean:
	$(MAKE) -C ./bootstrap DTC_LOC=$(DTC_LOC) \
		O=$(INSTALL_LOC) dt_clean 

phy_os.dt.dist:
	$(MAKE) -C ./bootstrap dt_distclean

#==========================================
# Generation of Xilinx FSBL (BL2)
#==========================================
fsbl $(BL2_BIN): $(HW_DESIGN_HDF) FORCE
	@echo "Compiling FSBL..."
	$(MAKE) -C ./bootstrap COMPILER_PATH=$(ELF_GCC_PATH) \
		HSI=$(HSI_BIN) INSTALL_LOC=$(INSTALL_LOC) fsbl

fsbl_clean:
	$(MAKE) -C ./bootstrap COMPILER_PATH=$(ELF_GCC_PATH) \
		INSTALL_LOC=$(INSTALL_LOC) $@

fsbl_distclean:
	$(MAKE) -C ./bootstrap $@

#==========================================
# Generation of PMU Firmware (PMUFW)
#==========================================
pmufw $(PMU_FW): $(HW_DESIGN_HDF) FORCE
	@echo "Compiling PMU Firmware..."
	$(MAKE) -C ./bootstrap COMPILER_PATH=$(MB_GCC_PATH) \
		HSI=$(HSI_BIN) INSTALL_LOC=$(INSTALL_LOC) pmufw

pmufw_clean:
	$(MAKE) -C ./bootstrap COMPILER_PATH=$(MB_GCC_PATH) \
		INSTALL_LOC=$(INSTALL_LOC) $@ 

pmufw_distclean:
	$(MAKE) -C ./bootstrap $@

#==========================================
# Generation of BOOT.bin
#==========================================
boot_bin: $(BOOT_BIN_OBJS) 
	@echo "Generating BOOT.bin image..."
	@mkdir -p $(INSTALL_LOC)
	$(MAKE) -C ./bootstrap BOOT_GEN=$(BOOT_GEN_BIN) WITH_BIT=$(BOOTBIN_WITH_BIT) \
		WITH_TOS=$(BOOTBIN_WITH_TOS) TOS=$(TOS)\
		O=$(INSTALL_LOC) $@

boot_bin_clean:
	$(MAKE) -C ./bootstrap O=$(INSTALL_LOC) $@

#==========================================
# Clean for bootstrap directory
#==========================================
bootstrap_clean: FORCE
	$(MAKE) -C ./bootstrap $@

#==========================================
# Intermediate files between HW and SW design
#==========================================
#ifneq ($(wildcard $(HW_DESIGN_HDF)), )
#$(HW_DESIGN_HDF): FORCE 
#	@echo "Hardware definition file is ready"
#	@mkdir -p $(HW_PLAT_TEMP)
#	@cp $(HW_DESIGN_HDF) $(HW_PLAT_TEMP)
#else
#$(HW_DESIGN_HDF): FORCE
#	$(error No hardware definition file, please inform your hardware design team to upload it)
#endif

ifneq ($(wildcard $(BITSTREAM)), )
$(BITSTREAM): FORCE
	@echo "Hardware bitstream file is ready"
else
$(BITSTREAM): FORCE
	$(error No bitstream file, please inform your hardware design team to upload it)
endif

#==========================================
# Hardware Design
#==========================================
hdf $(HW_DESIGN_HDF):
	@echo "Generating HDF file for Vivado project..."
	@mkdir -p $(HW_PLATFORM)
	$(MAKE) -C ./hardware VIVADO=$(VIVADO_BIN) O=$(HW_PLATFORM) hdf

hdf_clean:
	$(MAKE) -C ./hardware $@

#==========================================
# Hardware Design
#==========================================
vivado_prj: FORCE
	@echo "Executing $(HW_ACT) for Vivado project..."
	@mkdir -p $(HW_PLATFORM)
	$(MAKE) -C ./hardware VIVADO=$(VIVADO_BIN) HW_ACT=$(HW_ACT) HW_VAL="$(HW_VAL)" O=$(HW_PLATFORM) $@

vivado_prj_clean:
	$(MAKE) -C ./hardware $@

#==========================================
# Generated image clean
#==========================================
image_clean:
	@rm -rf $(HW_PLATFORM) $(INSTALL_LOC)

