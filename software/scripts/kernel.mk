KERN_SRC := $(SW_LOC)/linux
MODULE_SRC := $(SW_LOC)/modules
ifeq ($(ARCH),)
KERN_LOC := $(SW_LOC)/arm-linux
else
KERN_LOC := $(SW_LOC)/$(ARCH)-linux
endif

# TODO: set your Linux kernel compilation flags and targets
ifeq ($(ARCH),)
KERN_PLAT := arm64
else
KERN_PLAT := $(ARCH)
endif
KERN_COMPILE_FLAGS := ARCH=$(KERN_PLAT) O=$(KERN_LOC)/$(OS)
KERN_TARGET := all

# TODO: Change to your own Linux kernel configuration file name for physical os
ifeq ($(ARCH),)
phy_os-kern-config:= xilinx_zynqmp_defconfig
virt-kern-config:= defconfig
dom0-kern-config:= xilinx_zynqmp_xen_Dom0_defconfig
domU-kern-config:= xilinx_zynqmp_xen_DomU_defconfig
endif
ifeq ($(ARCH),riscv)
phy_os-kern-config:= riscv_serve_defconfig
endif

KERN_CONFIG_SRC := $(KERN_SRC)/arch/$(KERN_PLAT)/configs

# Empty $COMPILER_PATH means native compilation
# otherwise, it means cross compilation
ifneq ($(COMPILER_PATH),)
KERN_COMPILE_FLAGS += CROSS_COMPILE=$(CROSS_COMPILE)
endif

KERN_IMAGE_GEN := $(KERN_LOC)/$(OS)/arch/$(KERN_PLAT)/boot/Image

# kernel installation for cross compilation
ifneq ($(INSTALL_LOC),)
KERN_INSTALL_LOC := $(INSTALL_LOC)/$(OS)
endif
KERN_INSTALL_LOC ?= $(KERN_LOC)/$(OS)

KERN_IMAGE := $(KERN_INSTALL_LOC)/Image

# vmlinuz installation for cross compilation
# Boot partition of OS image would be mounted on /mnt/phy_os/boot in advance
# Root partition of OS image would be mounted on /mnt/phy_os/root in advance
ifneq ($(INSTALL_LOC),)
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

# Modules compilation objects
obj-modules-y := $(MODULES)
obj-modules-build-y := $(foreach obj,$(obj-modules-y),$(MODULE_SRC)/$(obj).ko)
obj-modules-objects-y := $(foreach obj,$(obj-modules-y),$(MODULE_SRC)/$(obj)/$(obj).ko)
obj-modules-clean-y := $(foreach obj,$(obj-modules-y),$(MODULE_SRC)/$(obj).ko.clean)

#==================================
# Linux kernel compilation
#==================================
linux: $(KERN_IMAGE_GEN) $(obj-modules-build-y) FORCE
	@mkdir -p $(KERN_INSTALL_LOC)/modules
	@cp $(KERN_IMAGE_GEN) $(KERN_IMAGE)
ifneq ($(wildcard $(obj-modules-objects-y)),)
	@mv $(obj-modules-objects-y) $(KERN_INSTALL_LOC)/modules
endif

$(KERN_IMAGE_GEN): $(KERN_LOC)/$(OS)/.config FORCE
	$(EXPORT_CC_PATH) && $(MAKE) -C $(KERN_SRC) \
		$(KERN_COMPILE_FLAGS) $(KERN_TARGET) -j 10

%.ko: FORCE
	$(EXPORT_CC_PATH) && $(MAKE) -C $(KERN_SRC) \
		$(KERN_COMPILE_FLAGS) \
		M=$(patsubst %.ko,%,$@) modules

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

linux_clean: $(obj-modules-clean-y)
	$(MAKE) -C $(KERN_SRC) O=$(KERN_LOC)/$(OS) clean 
	@rm -f $(KERN_IMAGE)

linux_distclean: $(obj-modules-clean-y)
	@rm -rf $(KERN_LOC)/$(OS) $(KERN_INSTALL_LOC)

%.ko.clean:
	$(EXPORT_CC_PATH) && $(MAKE) -C $(KERN_SRC) \
		$(KERN_COMPILE_FLAGS) \
		M=$(patsubst %.ko.clean,%,$@) clean

