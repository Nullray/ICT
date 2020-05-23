FPGA_ROOT := $(shell pwd)

# Hardware install file
O ?= $(FPGA_ROOT)
HDF_INSTALL := $(O)/system.hdf
BIT_INSTALL := $(O)/system.bit

# Vivado Auto-run tcl scripts
VIVADO_PRJ_TCL := $(FPGA_ROOT)/scripts/mk.tcl
VIVADO_FILE_TCL := $(FPGA_ROOT)/scripts/file_cp.tcl

ifneq ($(findstring $(FPGA_ACT), "dcp_chk"),)
VIVADO_MODE := gui
else
VIVADO_MODE := batch
endif

VIVADO_PRJ_FLAGS := -nojournal -nolog -mode $(VIVADO_MODE) -source $(VIVADO_PRJ_TCL) \
	-notrace -tclargs $(FPGA_ACT) "$(FPGA_VAL)" $(O)

# Related sources
TCL_SRC := $(wildcard scripts/*.tcl)
HDL_SRC := $(wildcard sources/hdl/*.v)
CONSTRAINTS_SRC := $(wildcard sources/constraints/*.xdc)

# Locations of Vivado project and generated files
VIVADO_PRJ_LOC := $(FPGA_ROOT)/vivado_prj
VIVADO_OUT := $(FPGA_ROOT)/vivado_out
SYNTH_RPT_LOC := $(VIVADO_OUT)/synth_rpt
IMPL_RPT_LOC := $(VIVADO_OUT)/impl_rpt
DCP_LOC := $(VIVADO_OUT)/dcp
VIVADO_LOG_LOC := $(VIVADO_OUT)/run_log

DIR_GEN_OBJ := $(VIVADO_PRJ_LOC) $(SYNTH_RPT_LOC) \
				$(IMPL_RPT_LOC) $(VIVADO_LOG_LOC) $(DCP_LOC)

.PHONY: FORCE

ifeq (${FPGA_ACT},)
vivado_prj: FORCE
	$(error Please specify the action to be lanuched for Vivado hardware design)
else
vivado_prj: FORCE
	@mkdir -p $(DIR_GEN_OBJ)
ifeq (${VIVADO_MODE},batch)
	@cd $(VIVADO_PRJ_LOC) && $(VIVADO) $(VIVADO_PRJ_FLAGS) 2>&1 | tee $(VIVADO_LOG_LOC)/$(FPGA_ACT).log
else
	@cd $(VIVADO_PRJ_LOC) && $(VIVADO) $(VIVADO_PRJ_FLAGS)
endif
endif

vivado_prj_clean: 
	@rm -rf $(VIVADO_PRJ_LOC) $(VIVADO_OUT)


