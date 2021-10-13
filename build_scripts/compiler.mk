# Specify cross-compiler for target FPGA board
ifeq ($(ARCH),)
LINUX_GCC_PATH := $($(FPGA_ARCH)_LINUX_GCC_PATH)
else
LINUX_GCC_PATH := $($(ARCH)_LINUX_GCC_PATH)
endif
ELF_GCC_PATH := $($(FPGA_ARCH)_ELF_GCC_PATH)

# Host machine to determine if it is cross compilation for Linux kernel
HOST := $(shell uname -m)

ifneq ($(HOST),aarch64)
SW_COMPILE_FLAG := ARCH=$(ARCH) COMPILER_PATH=$(LINUX_GCC_PATH) 
else
SW_COMPILE_FLAG := 
endif

