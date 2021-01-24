
ifneq (${DTC_LOC},)
TEMP_PATH := $(COMPILER_PATH):$(DTC_LOC)
else
TEMP_PATH := $(COMPILER_PATH)
endif

EXPORT_CC_PATH := export PATH=$(TEMP_PATH):$$PATH
SW_LOC := $(shell pwd)

# BL31: ARM Trusted Firmware (ATF)
ATF_SRC := $(SW_LOC)/atf
ATF_LOC := $(SW_LOC)/arm-atf
include scripts/atf.mk
ATF_CROSS_COMPILE_FLAGS += BUILD_BASE=$(ATF_LOC)

ifneq (${TOS},) 
TEE_SRC := $(SW_LOC)/tee
obj-tos-y := $(foreach obj,$(TOS),$(obj).tos)
obj-tos-clean-y := $(foreach obj,$(TOS),$(obj).tos.clean)
obj-tos-dist-y := $(foreach obj,$(TOS),$(obj).tos.dist)
ATF_CROSS_COMPILE_FLAGS += SPD=$(TOS)d
BL32_BIN := $(SW_LOC)/arm-tee/bl32.elf
include scripts/tee.mk
endif

ATF_ELF := $(ATF_LOC)/$(ATF_PLAT)/release/bl31/bl31.elf
BL31_BIN := $(ATF_LOC)/bl31.elf

# BL33: U-Boot
UBOOT_SRC := $(SW_LOC)/uboot
UBOOT_LOC := $(SW_LOC)/arm-uboot
include scripts/uboot.mk
UBOOT_CROSS_COMPILE_FLAGS += KBUILD_OUTPUT=$(UBOOT_LOC)

UBOOT_APP := $(UBOOT_LOC)/examples/standalone/zynqmp_daemon.bin

UBOOT_MKIMG := $(UBOOT_LOC)/tools/mkimage
UBOOT_SCR_FLAGS := -A arm -O linux -T script \
	-C none -a 0 -e 0 -n 'Custom BOOT config' \

# BL33: Linux kernel image
KERN_SRC := $(SW_LOC)/linux
KERN_LOC := $(SW_LOC)/arm-linux
include scripts/kernel.mk
KERN_COMPILE_FLAGS += O=$(KERN_LOC)/$(OS)
	
# INSTALL_LOC is empty means native compilation
# otherwise, it means cross compilation
ifneq (${INSTALL_LOC},)
KERN_COMPILE_FLAGS += CROSS_COMPILE=aarch64-linux-gnu-
endif

KERN_IMAGE_GEN := $(KERN_LOC)/$(OS)/arch/$(KERN_PLAT)/boot/Image

# kernel image installation for BH motherboard and other embedded boards
ifneq (${INSTALL_LOC},)
KERN_INSTALL_LOC := $(INSTALL_LOC)/$(OS)
endif
KERN_INSTALL_LOC ?= $(KERN_LOC)/$(OS)

KERN_IMAGE := $(KERN_INSTALL_LOC)/Image

# vmlinuz installation for NF/Fidus card
# It means native compilation when INSTALL_LOC is empty
# otherwise, it means cross compilation
ifneq (${INSTALL_LOC},)
VMLINUZ_INSTALL_LOC := /mnt/$(OS)
MODULES_INSTALL_LOC := /mnt/$(OS)/root
endif

# VM kernel compilation and installation 
# is based on aarch64 physical machine
# Boot partition of VM OS image would be mounted on /mnt/virt/boot
# Root partition of VM OS image would be mounted on /mnt/virt/root
ifeq ($(OS),virt)
VMLINUZ_INSTALL_LOC := /mnt/$(OS)
MODULES_INSTALL_LOC := /mnt/$(OS)/root
endif

#=====================================================
# NOTE: Initramfs would be automatically updated 
# after installation in the native kernel compilation
#=====================================================

# XEN 
XEN_SRC := $(SW_LOC)/xen
include scripts/xen.mk
XEN_IMAGE := $(XEN_SRC)/xen/xen

ifneq (${INSTALL_LOC},)
XEN_INSTALL_LOC := $(INSTALL_LOC)
endif
XEN_INSTALL_LOC ?= $(KERN_LOC)

XEN_UIMAGE := $(XEN_INSTALL_LOC)/xen.ub

# QEMU 
QEMU_SRC := $(SW_LOC)/qemu
QEMU_LOC := $(SW_LOC)/arm-qemu
include scripts/qemu.mk

# OpenBMC image
OBMC_IMG := $(OBMC_LOC)/*.rootfs.cpio.gz.u-boot

.PHONY: FORCE

#==================================
# ARM Trusted Firmware compilation 
#==================================
atf: $(obj-tos-y) FORCE
	$(EXPORT_CC_PATH) && $(MAKE) -C $(ATF_SRC) \
		$(ATF_CROSS_COMPILE_FLAGS) $(ATF_TARGET)
	@cp $(ATF_ELF) $(BL31_BIN)

atf_clean: $(obj-tos-clean-y)
	$(MAKE) -C $(ATF_SRC) BUILD_BASE=$(ATF_LOC) clean
	@rm -f $(BL31_BIN)

atf_distclean: $(obj-tos-dist-y)
	@rm -rf $(ATF_LOC)

%.tos: FORCE
	$(EXPORT_CC_PATH) && $(MAKE) -C \
		$(TEE_SRC)/$(patsubst %.tos,%,$@) \
		$($(patsubst %.tos,%,$@)-obj-flags) \
		$($(patsubst %.tos,%,$@)-target)
	@cp $($(patsubst %.tos,%,$@)-obj) $(BL32_BIN)

%.tos.clean:
	$(MAKE) -C $($(patsubst %.tos.clean,%,$@)) \
		$($(patsubst %.tos.clean,%,$@)-obj-clean) clean
	@rm -f $(BL32_BIN)

%.tos.dist:
	@rm -rf $($(patsubst %.tos.dist,%,$@)-loc)

#==================================
# XEN compilation
#==================================
xen: $(XEN_IMAGE)
	$(UBOOT_LOC)/tools/mkimage -A arm64 -C none -T kernel \
		-a 6000000 -e 6000000 \
		-n "xen.ub" -d $(XEN_IMAGE) $(XEN_UIMAGE)

$(XEN_IMAGE): FORCE 
	$(EXPORT_CC_PATH) && $(MAKE) -C $(XEN_SRC) \
		$(XEN_CROSS_COMPILE_FLAGS) $(XEN_TARGET) -j 10

xen_clean:
	$(MAKE) -C $(XEN_SRC) clean-xen 

xen_distclean:
	$(MAKE) -C $(XEN_SRC) distclean-xen

#==================================
# QEMU native compilation
#==================================
qemu: $(QEMU_LOC)/.qemu.cfg FORCE
	$(MAKE) -C $(QEMU_LOC)

qemu_install: FORCE
	$(MAKE) -C $(QEMU_LOC) install

$(QEMU_LOC)/.qemu.cfg:
	@mkdir -p $(QEMU_LOC)
	@cd $(QEMU_LOC) && \
		$(QEMU_SRC)/configure $(QEMU_CONFIG_FLAGS)
	@touch $(QEMU_LOC)/.qemu.cfg

qemu_clean:
	$(MAKE) -C $(QEMU_LOC) clean 

qemu_distclean:
	@rm -rf $(QEMU_LOC)

#==================================
# U-Boot compilation
#==================================
uboot: $(UBOOT_LOC)/.config FORCE
	$(EXPORT_CC_PATH) && $(MAKE) -C $(UBOOT_SRC) \
		$(UBOOT_CROSS_COMPILE_FLAGS) $(UBOOT_TARGET) -j 10
	@cp $(UBOOT_APP) $(UBOOT_LOC)/../../ready_for_download/$(DTB_LOC)/
ifneq ($(wildcard $(SW_LOC)/../fpga/design/$(FPGA_PRJ)/boot/boot.script),)
	$(UBOOT_MKIMG) $(UBOOT_SCR_FLAGS) \
		-d $(abspath $(SW_LOC)/../fpga/design/$(FPGA_PRJ)/boot/boot.script) \
		$(UBOOT_LOC)/../../ready_for_download/$(DTB_LOC)/boot.scr.uimg
endif

$(UBOOT_LOC)/.config: $(uboot-config-file)
	$(EXPORT_CC_PATH) && $(MAKE) -C $(UBOOT_SRC) \
		$(UBOOT_CROSS_COMPILE_FLAGS) $(uboot-config) olddefconfig

uboot_clean:
	$(MAKE) -C $(UBOOT_SRC) KBUILD_OUTPUT=$(UBOOT_LOC) clean 

uboot_distclean:
	@rm -rf $(UBOOT_LOC)

#==================================
# Linux kernel compilation
#==================================
linux: $(KERN_LOC)/$(OS)/.config FORCE
	$(EXPORT_CC_PATH) && $(MAKE) -C $(KERN_SRC) \
		$(KERN_COMPILE_FLAGS) $(KERN_TARGET) -j 10
	@mkdir -p $(KERN_INSTALL_LOC)
	@cp $(KERN_IMAGE_GEN) $(KERN_IMAGE)

linux_install: FORCE
	$(EXPORT_CC_PATH) && $(MAKE) -C $(KERN_SRC) \
		$(KERN_COMPILE_FLAGS) \
		INSTALL_PATH=$(VMLINUZ_INSTALL_LOC)/boot install
	$(EXPORT_CC_PATH) && $(MAKE) -C $(KERN_SRC) \
		$(KERN_COMPILE_FLAGS) \
		INSTALL_MOD_PATH=$(MODULES_INSTALL_LOC)/usr modules_install

$(KERN_LOC)/%/.config: $($(OS)-kern-config-file)
	$(EXPORT_CC_PATH) && $(MAKE) -C $(KERN_SRC) \
		$(KERN_COMPILE_FLAGS) $($(OS)-kern-config) olddefconfig

linux_clean:
	$(MAKE) -C $(KERN_SRC) O=$(KERN_LOC)/$(OS) clean 
	@rm -f $(KERN_IMAGE)

linux_distclean:
	@rm -rf $(KERN_LOC)/$(OS) $(KERN_INSTALL_LOC)

#==================================
# OpenBMC compilation
#==================================
openbmc: FORCE
	@bash scripts/openbmc.sh
	@cp $(OBMC_IMG) $(INSTALL_LOC)/obmc.cpio.gz

openbmc_clean:
	@rm -f $(INSTALL_LOC)/obmc.cpio.gz

openbmc_distclean:
	@rm -rf arm-openbmc

