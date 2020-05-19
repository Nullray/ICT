
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
ATF_CROSS_COMPILE_FLAGS += SPD=$(TOS)d
endif

ATF_ELF := $(ATF_LOC)/$(ATF_PLAT)/release/bl31/bl31.elf
BL31_BIN := $(ATF_LOC)/bl31.elf

# BL33: U-Boot
UBOOT_SRC :=$(SW_LOC)/uboot
UBOOT_LOC := $(SW_LOC)/arm-uboot
include scripts/uboot.mk
UBOOT_CROSS_COMPILE_FLAGS += KBUILD_OUTPUT=$(UBOOT_LOC)

UBOOT_CONFIGED := $(UBOOT_LOC)/.config

UBOOT_BIN := $(UBOOT_LOC)/u-boot.elf

# BL33: Linux kernel image
KERN_SRC := $(SW_LOC)/linux
KERN_LOC := $(SW_LOC)/arm-linux
include scripts/kernel.mk
KERN_IMAGE_GEN := $(KERN_LOC)/$(OS)/arch/$(KERN_PLAT)/boot/Image

ifneq (${INSTALL_LOC},)
KERN_INSTALL_LOC := $(INSTALL_LOC)/$(OS)
endif
KERN_INSTALL_LOC ?= $(KERN_LOC)/$(OS)

KERN_IMAGE := $(KERN_INSTALL_LOC)/Image

.PHONY: FORCE

#==================================
# ARM Trusted Firmware compilation 
#==================================
atf $(ATF_ELF): FORCE
	$(EXPORT_CC_PATH) && $(MAKE) -C $(ATF_SRC) \
		$(ATF_CROSS_COMPILE_FLAGS) $(ATF_TARGET)
	@cp $(ATF_ELF) $(BL31_BIN)

atf_clean:
	$(MAKE) -C $(ATF_SRC) clean
	@rm -f $(BL31_BIN)

atf_distclean:
	@rm -rf $(ATF_LOC)

#==================================
# U-Boot compilation
#==================================
uboot $(UBOOT_BIN): $(UBOOT_CONFIGED) FORCE
	$(EXPORT_CC_PATH) && $(MAKE) -C $(UBOOT_SRC) \
		$(UBOOT_CROSS_COMPILE_FLAGS) $(UBOOT_TARGET) -j 10

$(UBOOT_CONFIGED): $(UBOOT_CONFIG_FILE)
	$(EXPORT_CC_PATH) && $(MAKE) -C $(UBOOT_SRC) \
		$(UBOOT_CROSS_COMPILE_FLAGS) $(UBOOT_CONFIG) olddefconfig

uboot_clean:
	$(MAKE) -C $(UBOOT_SRC) clean 

uboot_distclean:
	@rm -rf $(UBOOT_LOC)

#==================================
# Linux kernel compilation
#==================================
linux: $(KERN_LOC)/$(OS)/.config FORCE
	$(EXPORT_CC_PATH) && $(MAKE) -C $(KERN_SRC) \
		$(KERN_CROSS_COMPILE_FLAGS) \
		O=$(KERN_LOC)/$(OS) $(KERN_TARGET) -j 10
	@mkdir -p $(KERN_INSTALL_LOC)
	@cp $(KERN_IMAGE_GEN) $(KERN_IMAGE)

$(KERN_LOC)/%/.config: $($(OS)-config-file)
	@mkdir -p $(KERN_LOC)/$(OS)
	$(EXPORT_CC_PATH) && $(MAKE) -C $(KERN_SRC) \
		$(KERN_CROSS_COMPILE_FLAGS) \
		O=$(KERN_LOC)/$(OS) $($(OS)-config) menuconfig

linux_clean:
	$(MAKE) -C $(KERN_SRC) O=$(KERN_LOC)/$(OS) clean 
	@rm -f $(KERN_IMAGE_GEN)

linux_distclean:
	@rm -rf $(KERN_LOC)/$(OS) $(KERN_INSTALL_LOC)/$(OS)

