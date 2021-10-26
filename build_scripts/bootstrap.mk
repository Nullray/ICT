PRJ_DT_LOC := $(abspath ./fpga/design/$(FPGA_PRJ)/dt)

ifneq ($(ARCH),)
USER_DT_LOC := $(user-dt-loc)
USER_DT := $(user-dt-top)
endif

# TODO: Change to your own compilation flags
fsbl-flag := COMPILER_PATH=$(ELF_GCC_PATH) \
	    HSI=$(HSI_BIN) HDF_FILE=$(SYS_HDF) \
	    FPGA_ARCH=$(FPGA_ARCH) FPGA_PROC=$(FPGA_PROC) FPGA_BD=$(FPGA_BD)

servefw-flag := CROSS_COMPILE=$(ELF_GCC_PREFIX) WITH_BIT=$(WITH_BIT) \
	    FPGA_ARCH=$(FPGA_ARCH) FPGA_PROC=$(FPGA_PROC)

pmufw-flag := COMPILER_PATH=$(MB_GCC_PATH) \
	    HSI=$(HSI_BIN) HDF_FILE=$(SYS_HDF)

dt-flag := DTC_LOC=$(DTC_LOC) \
	HSI=$(HSI_BIN) HDF_FILE=$(SYS_HDF) \
	FPGA_BD=$(FPGA_BD) O=$(INSTALL_LOC)/$(ARCH) \
	PRJ_DT_LOC=$(PRJ_DT_LOC) \
	USER_DT_LOC=$(USER_DT_LOC) USER_DT=$(USER_DT) $(user-dt-flag)

ipxe-flag := COMPILER_PATH=$(LINUX_GCC_PATH) \
	TARGET_IQN=$(IQN) TFTP_SERVER=$(TFTP) \
	INSTALL_LOC=$(shell pwd)/ready_for_download

ifeq ($(ARCH),riscv)
zsbl-flag := COMPILER_PATH=$(ELF_GCC_PATH) \
	CROSS_COMPILE=$(ELF_GCC_PREFIX)
endif

# common bootstrap target
obj-bootstrap-y := fsbl pmufw dt ipxe
ifeq ($(ARCH),riscv)
obj-bootstrap-y += zsbl
endif
obj-bootstrap-clean-y := $(foreach obj,$(obj-bootstrap-y),$(obj)_clean)
obj-bootstrap-dist-y := $(foreach obj,$(obj-bootstrap-y),$(obj)_distclean)

# common bootstrap compilation
$(obj-bootstrap-y): FORCE
	@echo "Compiling $@..."
	$(MAKE) -C ./bootstrap \
		$($(patsubst %,%-flag,$@)) \
		$($(patsubst %,%-prj-flag,$@)) $@

servefw: fsbl FORCE
	$(MAKE) -C ./bootstrap COMPILER_PATH=$(ELF_GCC_PATH) \
		USER_FLAGS="$($(patsubst %,%-flag,$@))" $@

$(obj-bootstrap-clean-y):
	$(MAKE) -C ./bootstrap \
		$($(patsubst %_clean,%-flag,$@)) $@

servefw_clean servefw_distclean: fsbl_distclean 
	$(MAKE) -C ./bootstrap $@

$(obj-bootstrap-dist-y):
	$(MAKE) -C ./bootstrap \
		$($(patsubst %_distclean,%-flag,$@)) $@

# PMUFW binary generation for OpenBMC compilation
pmufw_bin: FORCE
	@echo "Generating PMU Firmware Binary..."
	$(MAKE) -C ./bootstrap COMPILER_PATH=$(MB_GCC_PATH) $@ 
	@cp ./bootstrap/pmufw/*.bin $(OBMC_LOC)

# Device Tree install for vmlinux install in cross compilation
dt_install: FORCE
	@cp $(INSTALL_LOC)/zynqmp.dtb \
		/mnt/phy_os/boot/efi/dtb/xilinx/
	
