PRJ_SPEC_DT_LOC := ./fpga/design/$(FPGA_PRJ)/dt
PL_DT := $(abspath $(PRJ_SPEC_DT_LOC)/pl.dtsi)
PS_DT := $(abspath $(PRJ_SPEC_DT_LOC)/design.dtsi)
SYS_DT := $(abspath $(PRJ_SPEC_DT_LOC)/design_top.dtsi)

# TODO: Change to your own compilation flags
fsbl_flag := COMPILER_PATH=$(ELF_GCC_PATH) \
	    HSI=$(HSI_BIN) HDF_FILE=$(SYS_HDF) \
	    FPGA_ARCH=$(FPGA_ARCH) FPGA_PROC=$(FPGA_PROC) FPGA_BD=$(FPGA_BD)

pmufw_flag := COMPILER_PATH=$(MB_GCC_PATH) \
	    HSI=$(HSI_BIN) HDF_FILE=$(SYS_HDF)

dt_flag := DTC_LOC=$(DTC_LOC) \
	HSI=$(HSI_BIN) HDF_FILE=$(SYS_HDF) \
	FPGA_BD=$(FPGA_BD) O=$(INSTALL_LOC) \
	PL_DT=$(PL_DT) PS_DT=$(PS_DT) SYS_DT=$(SYS_DT)

ipxe_flag := COMPILER_PATH=$(LINUX_GCC_PATH) \
	TARGET_IQN=$(IQN) TFTP_SERVER=$(TFTP) \
	INSTALL_LOC=$(shell pwd)/ready_for_download

# common bootstrap target
obj-bootstrap-y := fsbl pmufw dt ipxe
obj-bootstrap-clean-y := $(foreach obj,$(obj-bootstrap-y),$(obj)_clean)
obj-bootstrap-dist-y := $(foreach obj,$(obj-bootstrap-y),$(obj)_distclean)

# common bootstrap compilation
$(obj-bootstrap-y): FORCE
	@echo "Compiling $@..."
	$(MAKE) -C ./bootstrap $($(patsubst %,%_flag,$@)) $@

$(obj-bootstrap-clean-y):
	$(MAKE) -C ./bootstrap O=$(INSTALL_LOC) $@

$(obj-bootstrap-dist-y):
	$(MAKE) -C ./bootstrap O=$(INSTALL_LOC) $@

# PMUFW binary generation for OpenBMC compilation
pmufw_bin: FORCE
	@echo "Generating PMU Firmware Binary..."
	$(MAKE) -C ./bootstrap COMPILER_PATH=$(MB_GCC_PATH) $@ 
	@cp ./bootstrap/pmufw/*.bin $(OBMC_LOC)

# Device Tree install for vmlinux install in cross compilation
dt_install: FORCE
	@cp $(INSTALL_LOC)/zynqmp.dtb \
		/mnt/phy_os/boot/efi/dtb/xilinx/

# Zynq baremetal firmware for SERVE
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
	
