# TODO: set your U-Boot compilation flags and targets
UBOOT_CROSS_COMPILE_FLAGS := ARCH=arm \
	CROSS_COMPILE=aarch64-linux-gnu- \
	EXT_DTB=$(UBOOT_SRC)/../../ready_for_download/system.dtb
UBOOT_TARGET := all

# TODO: Change to your own U-Boot configuration file name
phy_os-uboot-config := xilinx_zynqmp_zcu102_revB_defconfig
phy_os-uboot-config-file := $(UBOOT_SRC)/configs/$(phy_os-uboot-config)
