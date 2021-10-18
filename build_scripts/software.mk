# OpenBMC
OBMC_MACHINE := zcu102-zynqmp
OBMC_LOC := $(abspath ./software/arm-openbmc/tmp/deploy/images/$(OBMC_MACHINE))

# Linux kernel (i.e., Physical machine and Virtual machine)
OS_KERN := phy_os virt

obj-os-y := $(foreach obj,$(OS_KERN),$(obj).os)
obj-os-install-y := $(foreach obj,$(OS_KERN),$(obj).os.install)
obj-os-clean-y := $(foreach obj,$(OS_KERN),$(obj).os.clean)
obj-os-dist-y := $(foreach obj,$(OS_KERN),$(obj).os.dist)

# software list (QEMU needs native compilation on aarch64 machine)
obj-sw-y := atf uboot qemu xen openbmc
ifeq ($(ARCH),riscv)
obj-sw-y += opensbi
endif
obj-sw-clean-y := $(foreach obj,$(obj-sw-y),$(obj)_clean)
obj-sw-dist-y := $(foreach obj,$(obj-sw-y),$(obj)_distclean)

NEED_INSTALL := INSTALL_LOC=$(INSTALL_LOC)

# TODO: Change to your own compilation flags
atf-flag := TOS=$(TOS)

uboot-flag := FPGA_PRJ=$(FPGA_PRJ) DTC_LOC=$(DTC_LOC) DTB_LOC=$(FPGA_TARGET)

xen-flag := $(NEED_INSTALL)
	 
kernel-flag := $(NEED_INSTALL)

openbmc-flag := $(NEED_INSTALL) OBMC_LOC=$(OBMC_LOC)

ifeq ($(ARCH),riscv)
opensbi-flag := HART_COUNT=$(RV_HART_CNT) \
	RV_TARGET=$(RV_TARGET) \
	PLATFORM=ict \
	SERVE_PLAT=$(SERVE_PLAT) \
	WITH_SM=$(WITH_SM) \
	SM_ARM_ASSIST=$(SM_ARM_ASSIST)
endif

# compilation targets
$(obj-sw-y): dt FORCE
	@echo "Compiling $@..."
	$(MAKE) -C ./software $(SW_COMPILE_FLAG) \
		$($(patsubst %,%-flag,$@)) \
		$($(patsubst %,%-prj-flag,$@)) $@

ifeq ($(ARCH),riscv)
uboot_bin: uboot FORCE
	$(MAKE) -C ./software $(SW_COMPILE_FLAG) \
		$($(patsubst %,%-flag,$@)) \
		$($(patsubst %,%-prj-flag,$@)) $@
endif

%.os: FORCE
	@echo "Compiling $@..."
	$(MAKE) -C ./software $(SW_COMPILE_FLAG) \
		$(kernel-flag) OS=$(patsubst %.os,%,$@) linux

%.os.install: FORCE
	$(MAKE) -C ./software $(kernel-flag) \
		OS=$(patsubst %.os.install,%,$@) linux_install

$(obj-sw-clean-y):
	$(MAKE) -C ./software $(SW_COMPILE_FLAG) \
		$($(patsubst %_clean,%-flag,$@)) \
		$($(patsubst %_clean,%-prj-flag,$@)) $@

%.os.clean:
	$(MAKE) -C ./software $(SW_COMPILE_FLAG) $(kernel-flag) \
		OS=$(patsubst %.os.clean,%,$@) linux_clean

$(obj-sw-dist-y):
	$(MAKE) -C ./software $(SW_COMPILE_FLAG) \
		$($(patsubst %_distclean,%-flag,$@)) \
		$($(patsubst %_distclean,%-prj-flag,$@)) $@

%.os.dist:
	$(MAKE) -C ./software $(SW_COMPILE_FLAG) $(kernel-flag) \
		OS=$(patsubst %.os.dist,%,$@) linux_distclean

