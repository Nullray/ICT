
ifneq (${DTC_LOC},)
TEMP_PATH := $(COMPILER_PATH):$(DTC_LOC)
else
TEMP_PATH := $(COMPILER_PATH)
endif

EXPORT_CC_PATH := export PATH=$(TEMP_PATH):$$PATH
SW_LOC := $(shell pwd)

.PHONY: FORCE

# BL32: Trusted Execution Environment (TEE)
include scripts/tee.mk

# BL31: ARM Trusted Firmware (ATF)
include scripts/atf.mk

# BL33: U-Boot
include scripts/uboot.mk

# BL33: Linux kernel image
include scripts/kernel.mk

# QEMU hypervisor 
include scripts/qemu.mk

# XEN hypervisor 
include scripts/xen.mk

# OpenBMC
include scripts/openbmc.mk

# OpenSBI
include scripts/opensbi.mk
