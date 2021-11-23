UBOOT_SRC := $(SW_LOC)/uboot
ifeq ($(ARCH),)
UBOOT_ARCH := arm
else
UBOOT_ARCH := $(ARCH)
endif
UBOOT_LOC := $(SW_LOC)/$(UBOOT_ARCH)-uboot

# TODO: set your U-Boot compilation flags and targets
UBOOT_CROSS_COMPILE_FLAGS := ARCH=$(UBOOT_ARCH) \
	KBUILD_OUTPUT=$(UBOOT_LOC) \
	CROSS_COMPILE=$(CROSS_COMPILE)

# external DTB location
ifeq ($(ARCH),)
UBOOT_DTB := zynqmp.dtb
else
UBOOT_DTB := $(USER_DTB)
endif

UBOOT_CROSS_COMPILE_FLAGS += \
        EXT_DTB=$(UBOOT_LOC)/../../ready_for_download/$(DTB_LOC)/$(UBOOT_DTB)

ifeq ($(ARCH),riscv)
UBOOT_TARGET := u-boot
else
UBOOT_TARGET := u-boot.elf
endif

# TODO: Change to your own U-Boot configuration file name
ifeq ($(ARCH),)
uboot-config := xilinx_zynqmp_virt_defconfig
else
uboot-config := $(USER_CONFIG)
endif
uboot-config-file := $(UBOOT_SRC)/configs/$(uboot-config)

# TODO: Add your own U-Boot baremetal daemon for ZynqMP
uboot-app-y := zynqmp_daemon

UBOOT_APP_LOC := $(UBOOT_LOC)/examples/standalone
UBOOT_APP := $(foreach obj,$(uboot-app-y),$(UBOOT_APP_LOC)/$(obj))

# Compilation of custom boot script
UBOOT_MKIMG := $(UBOOT_LOC)/tools/mkimage
UBOOT_SCR_FLAGS := -A arm -O linux -T script \
	-C none -a 0 -e 0 -n 'Custom BOOT config' \

# select custom boot script
ifeq ($(ARCH),)
UBOOT_SCR := $(SW_LOC)/../fpga/design/$(FPGA_PRJ)/boot/boot.script
else
ifneq ($(BOOT_SCR),)
UBOOT_SCR := $(SW_LOC)/../fpga/design/$(FPGA_PRJ)/boot/$(BOOT_SCR)
else
UBOOT_SCR :=
endif
endif

# U-Boot binary file as the OpenSBI payload for RISC-V
ifeq ($(ARCH),riscv)
UBOOT_ELF := $(UBOOT_LOC)/$(UBOOT_TARGET)
UBOOT_BIN := $(UBOOT_LOC)/uboot.bin

UBOOT_OBJCOPY_FLAGS := -S -O binary --set-section-flags .bss=alloc,load,contents
endif

# U-Boot compilation
ifeq ($(ARCH),riscv)
uboot_bin: FORCE
	$(EXPORT_CC_PATH) && \
	$(CROSS_COMPILE)objcopy \
	$(UBOOT_OBJCOPY_FLAGS) $(UBOOT_ELF) $(UBOOT_BIN)
endif

uboot: $(UBOOT_LOC)/.config FORCE
	$(EXPORT_CC_PATH) && $(MAKE) -C $(UBOOT_SRC) \
		$(UBOOT_CROSS_COMPILE_FLAGS) $(UBOOT_TARGET) -j 10
ifneq ($(wildcard $(UBOOT_APP)),)
	@cp $(UBOOT_APP) $(UBOOT_LOC)/../../ready_for_download/$(DTB_LOC)/
endif
ifneq ($(UBOOT_SCR),)
ifneq ($(wildcard $(UBOOT_SCR)),)
	$(UBOOT_MKIMG) $(UBOOT_SCR_FLAGS) \
		-d $(abspath $(UBOOT_SCR)) \
		$(UBOOT_LOC)/../../ready_for_download/$(DTB_LOC)/boot.scr.uimg
endif
endif

$(UBOOT_LOC)/.config: $(uboot-config-file)
	$(EXPORT_CC_PATH) && $(MAKE) -C $(UBOOT_SRC) \
		$(UBOOT_CROSS_COMPILE_FLAGS) $(uboot-config) olddefconfig

uboot_clean:
	$(MAKE) -C $(UBOOT_SRC) KBUILD_OUTPUT=$(UBOOT_LOC) clean 

uboot_distclean:
	@rm -rf $(UBOOT_LOC)

