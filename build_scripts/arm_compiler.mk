# Specify cross-compiler for target FPGA board
LINUX_GCC_PATH := $($(FPGA_ARCH)_LINUX_GCC_PATH)
ELF_GCC_PATH := $($(FPGA_ARCH)_ELF_GCC_PATH)

# Host machine to determine if it is cross compilation for Linux kernel
HOST := $(shell uname -m)

ifneq ($(HOST),aarch64)
SW_COMPILE_FLAG := COMPILER_PATH=$(LINUX_GCC_PATH)
else
SW_COMPILE_FLAG := 
endif

