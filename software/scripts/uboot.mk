# TODO: set your U-Boot compilation flags and targets
UBOOT_CROSS_COMPILE_FLAGS := ARCH=arm \
	CROSS_COMPILE=aarch64-linux-gnu- \
	EXT_DTB=$(UBOOT_SRC)/../../bootstrap/dt/system.dtb
UBOOT_TARGET := all

# TODO: Change to your own U-Boot configuration file name
UBOOT_CONFIG := xilinx_zynqmp_zcu102_revB_defconfig
UBOOT_CONFIG_FILE := $(UBOOT_SRC)/configs/$(UBOOT_CONFIG)
