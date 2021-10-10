KERN_SRC := $(SW_LOC)/linux
KERN_LOC := $(SW_LOC)/arm-linux

# TODO: set your Linux kernel compilation flags and targets
KERN_PLAT := arm64
KERN_COMPILE_FLAGS := ARCH=$(KERN_PLAT) O=$(KERN_LOC)/$(OS)
KERN_TARGET := all

# TODO: Change to your own Linux kernel configuration file name for physical os
phy_os-kern-config:= xilinx_zynqmp_defconfig
virt-kern-config:= defconfig
dom0-kern-config:= xilinx_zynqmp_xen_Dom0_defconfig
domU-kern-config:= xilinx_zynqmp_xen_DomU_defconfig

KERN_CONFIG_SRC := $(KERN_SRC)/arch/$(KERN_PLAT)/configs

# Empty INSTALL_LOC means native compilation
# otherwise, it means cross compilation
ifneq (${INSTALL_LOC},)
KERN_COMPILE_FLAGS += CROSS_COMPILE=aarch64-linux-gnu-
endif

KERN_IMAGE_GEN := $(KERN_LOC)/$(OS)/arch/$(KERN_PLAT)/boot/Image

# kernel installation for cross compilation
ifneq (${INSTALL_LOC},)
KERN_INSTALL_LOC := $(INSTALL_LOC)/$(OS)
endif
KERN_INSTALL_LOC ?= $(KERN_LOC)/$(OS)

KERN_IMAGE := $(KERN_INSTALL_LOC)/Image

# vmlinuz installation for cross compilation
# Boot partition of OS image would be mounted on /mnt/phy_os/boot in advance
# Root partition of OS image would be mounted on /mnt/phy_os/root in advance
ifneq (${INSTALL_LOC},)
VMLINUZ_INSTALL_LOC := /mnt/$(OS)
MODULES_INSTALL_LOC := /mnt/$(OS)/root
endif

# VM kernel compilation and installation 
# is based on aarch64 physical machine (native compilation)
# Boot partition of VM OS image would be mounted on /mnt/virt/boot in advance
# Root partition of VM OS image would be mounted on /mnt/virt/root in advance
ifeq ($(OS),virt)
VMLINUZ_INSTALL_LOC := /mnt/$(OS)
MODULES_INSTALL_LOC := /mnt/$(OS)/root
endif

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

$(KERN_LOC)/%/.config: $(KERN_CONFIG_SRC)/$($(OS)-kern-config)
	$(EXPORT_CC_PATH) && $(MAKE) -C $(KERN_SRC) \
		$(KERN_COMPILE_FLAGS) $($(OS)-kern-config) olddefconfig

linux_clean:
	$(MAKE) -C $(KERN_SRC) O=$(KERN_LOC)/$(OS) clean 
	@rm -f $(KERN_IMAGE)

linux_distclean:
	@rm -rf $(KERN_LOC)/$(OS) $(KERN_INSTALL_LOC)

