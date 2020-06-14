# TODO: set your Linux kernel compilation flags and targets
KERN_PLAT := arm64
KERN_CROSS_COMPILE_FLAGS := ARCH=$(KERN_PLAT) \
	CROSS_COMPILE=aarch64-linux-gnu-
KERN_TARGET := all

# TODO: Change to your own Linux kernel configuration file name for physical os
phy_os-kern-config:= xilinx_zynqmp_defconfig
phy_os-kern-config-file := $(KERN_SRC)/arch/$(KERN_PLAT)/configs/$(phy_os-kern-config)
dom0-kern-config:= xilinx_zynqmp_xen_Dom0_defconfig
dom0-kern-config-file := $(KERN_SRC)/arch/$(KERN_PLAT)/configs/$(dom0-kern-config)
domU-kern-config:= xilinx_zynqmp_xen_DomU_defconfig
domU-kern-config-file := $(KERN_SRC)/arch/$(KERN_PLAT)/configs/$(domU-kern-config)

