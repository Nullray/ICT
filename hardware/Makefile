HW_ROOT := $(shell pwd)

# Hardware install file
O ?= $(HW_ROOT)
HDF_INSTALL := $(O)/system.hdf
BIT_INSTALL := $(O)/system.bit

# Vivado Auto-run tcl scripts
VIVADO_PRJ_TCL := $(HW_ROOT)/scripts/mk.tcl
VIVADO_FILE_TCL := $(HW_ROOT)/scripts/file_cp.tcl

ifneq ($(findstring $(HW_ACT), "dcp_chk"), )
VIVADO_MODE := gui
else
VIVADO_MODE := batch
endif

VIVADO_PRJ_FLAGS := -nojournal -nolog -mode $(VIVADO_MODE) -source $(VIVADO_PRJ_TCL) -tclargs $(HW_ACT) "$(HW_VAL)" $(O)

# Related sources
TCL_SRC := $(wildcard scripts/*.tcl)
HDL_SRC := $(wildcard sources/hdl/*.v)
CONSTRAINTS_SRC := $(wildcard sources/constraints/*.xdc)

# Locations of Vivado project and generated files
VIVADO_PRJ_LOC := $(HW_ROOT)/vivado_prj
SYNTH_RPT_LOC := $(HW_ROOT)/vivado_out/synth_rpt
IMPL_RPT_LOC := $(HW_ROOT)/vivado_out/impl_rpt
DCP_LOC := $(HW_ROOT)/vivado_out/dcp
VIVADO_LOG_LOC := $(HW_ROOT)/vivado_out/run_log

DIR_GEN_OBJ := $(VIVADO_PRJ_LOC) $(SYNTH_RPT_LOC) \
				$(IMPL_RPT_LOC) $(VIVADO_LOG_LOC) $(DCP_LOC)

.PHONY: FORCE

ifeq (${HW_ACT},none)
vivado_prj: FORCE
	$(error Please specify the action to be lanuched for Vivado hardware design)
else
vivado_prj: FORCE
	@mkdir -p $(DIR_GEN_OBJ)
ifeq (${VIVADO_MODE},batch)
	@cd $(VIVADO_PRJ_LOC) && $(VIVADO) $(VIVADO_PRJ_FLAGS) 2>&1 | tee $(VIVADO_LOG_LOC)/$(HW_ACT).log
else
	@cd $(VIVADO_PRJ_LOC) && $(VIVADO) $(VIVADO_PRJ_FLAGS)
endif
endif

vivado_prj_clean: 
	@rm -rf $(VIVADO_PRJ_LOC)


