# TODO: Vivado IDE version and installed location
VIVADO_VERSION ?= 2019.1
VIVADO_TOOL_BASE ?= /opt/Xilinx_$(VIVADO_VERSION)

# TODO: Device Tree Compiler (DTC)
DTC_LOC := /opt/dtc

# Vivado and SDK tool executable binary location
VIVADO_TOOL_PATH := $(VIVADO_TOOL_BASE)/Vivado/$(VIVADO_VERSION)/bin
SDK_TOOL_PATH := $(VIVADO_TOOL_BASE)/SDK/$(VIVADO_VERSION)/bin

# Cross-compiler location
COMPILER_BASE := $(VIVADO_TOOL_BASE)/SDK/$(VIVADO_VERSION)/gnu
#=================================================
# aarch-linux-gnu- (zynqmp_LINUX) : used for compilation of uboot, Linux kernel, ATF and other drivers on ZynqMP
# aarch-none-gnu- (zynqmp_ELF) : used for compilation of FSBL on ZynqMP
# arm-linux-gnueabihf- (zynq_LINUX) : used for compilation of uboot on Zynq
# arm-none-eabi- (zynq_ELF) : used for compilation of FSBL on Zynq
# mb- (microblaze-xilinx-elf-) : used for compilation of PMU Firmware
# riscv64-unknown-linux-gnu- (riscv-LINUX) : used for compilation of RISC-V prototyping software
#=================================================
zynqmp_LINUX_GCC_PATH := $(COMPILER_BASE)/aarch64/lin/aarch64-linux/bin
zynqmp_ELF_GCC_PATH := $(COMPILER_BASE)/aarch64/lin/aarch64-none/bin
zynq_LINUX_GCC_PATH := $(COMPILER_BASE)/aarch32/lin/gcc-arm-linux-gnueabi/bin
zynq_ELF_GCC_PATH := $(COMPILER_BASE)/aarch32/lin/gcc-arm-none-eabi/bin
MB_GCC_PATH := $(COMPILER_BASE)/microblaze/lin/bin
# TODO: Change to your install directory of RISC-V cross compiler
riscv_LINUX_GCC_PATH := /opt/riscv64-linux/bin
riscv_ELF_GCC_PATH := $(riscv_LINUX_GCC_PATH)

# TODO: change to your own prefix of cross compilers
zynqmp_LINUX_GCC_PREFIX := aarch64-linux-gnu-
zynqmp_ELF_GCC_PREFIX := aarch64-none-elf-
zynq_LINUX_GCC_PREFIX := arm-linux-gnueabi-
zynq_ELF_GCC_PREFIX := arm-none-eabi-
riscv_LINUX_GCC_PREFIX := riscv64-unknown-linux-gnu-
riscv_ELF_GCC_PREFIX := $(riscv_LINUX_GCC_PREFIX)

# Leveraged Vivado tools
VIVADO_BIN := $(VIVADO_TOOL_PATH)/vivado
HSI_BIN := $(SDK_TOOL_PATH)/hsi
BOOT_GEN_BIN := $(SDK_TOOL_PATH)/bootgen

