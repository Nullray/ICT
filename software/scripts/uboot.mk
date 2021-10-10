UBOOT_SRC := $(SW_LOC)/uboot
UBOOT_LOC := $(SW_LOC)/arm-uboot

# TODO: set your U-Boot compilation flags and targets
UBOOT_CROSS_COMPILE_FLAGS := ARCH=arm \
	CROSS_COMPILE=aarch64-linux-gnu- \
	EXT_DTB=$(UBOOT_LOC)/../../ready_for_download/$(DTB_LOC)/zynqmp.dtb \
	KBUILD_OUTPUT=$(UBOOT_LOC)
UBOOT_TARGET := u-boot.elf

# TODO: Change to your own U-Boot configuration file name
uboot-config := xilinx_zynqmp_virt_defconfig
uboot-config-file := $(UBOOT_SRC)/configs/$(uboot-config)

# TODO: Add your own U-Boot baremetal daemon
uboot-app-y := zynqmp_daemon

UBOOT_APP_LOC := $(UBOOT_LOC)/examples/standalone
UBOOT_APP := $(foreach obj,$(uboot-app-y),$(UBOOT_APP_LOC)/$(obj))

# Compilation of custom boot script
UBOOT_MKIMG := $(UBOOT_LOC)/tools/mkimage
UBOOT_SCR_FLAGS := -A arm -O linux -T script \
	-C none -a 0 -e 0 -n 'Custom BOOT config' \

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

