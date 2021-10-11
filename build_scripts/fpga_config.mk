# Specification of Board, Chipset and Project
FPGA_BD ?= nf
FPGA_PRJ := mpsoc
FPGA_TARGET := $(FPGA_PRJ)_$(FPGA_BD)

# Potential list of boards using Zynq
ARMv7_BOARDS := pynq serve_d

ifneq ($(findstring $(FPGA_BD),$(ARMv7_BOARDS)),)
FPGA_ARCH := zynq
FPGA_PROC := ps7_cortexa9_0
else
FPGA_ARCH := zynqmp
FPGA_PROC := psu_cortexa53_0
endif

