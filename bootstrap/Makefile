
ifneq (${COMPILER_PATH}, )
EXPORT_CC_PATH := export PATH=$(COMPILER_PATH):$$PATH
endif

ifneq (${DTC_LOC}, )
EXPORT_DTC_PATH := export PATH=$(DTC_LOC):$$PATH
else
EXPORT_DTC_PATH := $$PATH
endif

BOOT_STRAP_LOC := $(shell pwd)

HSI_FLAGS := -nojournal -nolog -mode batch

# BL2: ZynqMP First-Stage Boot Loader (FSBL)
FSBL_LOC := $(BOOT_STRAP_LOC)/fsbl
FSBL_GEN_TCL := $(BOOT_STRAP_LOC)/scripts/fsbl.tcl
FSBL_HSI_FLAGS := $(HSI_FLAGS) -source $(FSBL_GEN_TCL) \
	-tclargs $(HDF_FILE) $(FSBL_LOC)

FSBL_BIN_GEN := $(FSBL_LOC)/executable.elf
FSBL_BIN := $(FSBL_LOC)/bl2.elf

# PMU Firmware (PMUFW)
PMUFW_LOC := $(BOOT_STRAP_LOC)/pmufw
PMUFW_GEN_TCL := $(BOOT_STRAP_LOC)/scripts/pmufw.tcl
PMUFW_HSI_FLAGS := $(HSI_FLAGS) -source $(PMUFW_GEN_TCL) \
	-tclargs $(HDF_FILE) $(PMUFW_LOC)

PMUFW_BIN_GEN := $(PMUFW_LOC)/executable.elf
PMUFW_BIN := $(PMUFW_LOC)/pmufw.elf

# Device Tree Source and Blob (DTS and DTB)
DT_GEN := $(BOOT_STRAP_LOC)/dt-gen
DT_LOC := $(BOOT_STRAP_LOC)/dt
DT_GEN_TCL := $(BOOT_STRAP_LOC)/scripts/dt.tcl

DT_HSI_FLAGS := $(HSI_FLAGS) -source $(DT_GEN_TCL) \
	-tclargs $(HDF_FILE) $(DT_LOC) $(DT_GEN)

DTS := $(DT_LOC)/system-top.dts
DTB := $(DT_LOC)/system.dtb

# BOOT.bin
BOOT_BIN_LOC := $(BOOT_STRAP_LOC)/boot_bin

BIF_GEN := $(BOOT_STRAP_LOC)/scripts/bif_gen.sh
BIF_FILE := $(BOOT_BIN_LOC)/boot_gen.bif

#BOOT_GEN_FLAGS := -arch zynqmp -packagename $(CHIP) \
	-w on -image $(BIF_FILE) -log info

BOOT_GEN_FLAGS := -arch zynqmp -w on \
	-image $(BIF_FILE) -log info

ifneq ($(O),)
BOOT_BIN := $(O)/$(OS)/BOOT.bin
KERN_DTB := $(O)/system.dtb
endif
BOOT_BIN ?= $(BOOT_BIN_LOC)/BOOT.bin
KERN_DTB ?= $(DT_LOC)/system.dtb

BOOT_GEN_FLAGS += -o $(BOOT_BIN)

.PHONY: FORCE

#==========================================
# ZynqMP FSBL compilation 
#==========================================
fsbl: $(FSBL_BIN)

$(FSBL_BIN): .fsbl_gen FORCE
	$(EXPORT_CC_PATH) && $(MAKE) -C $(FSBL_LOC)
	@cp $(FSBL_BIN_GEN) $(FSBL_BIN)

.fsbl_gen:
	@$(HSI) $(FSBL_HSI_FLAGS)
	@touch $@

fsbl_clean:
	$(MAKE) -C $(FSBL_LOC) clean
	@rm -f $(FSBL_BIN)

fsbl_distclean:
	@rm -rf $(FSBL_LOC) .fsbl_gen

#==========================================
# PMU Firware (PMUFW) compilation 
#==========================================
pmufw: $(PMUFW_BIN)

$(PMUFW_BIN): .pmufw_gen FORCE
	$(EXPORT_CC_PATH) && $(MAKE) -C $(PMUFW_LOC)
	@cp $(PMUFW_BIN_GEN) $(PMUFW_BIN)

.pmufw_gen:
	@$(HSI) $(PMUFW_HSI_FLAGS)
	@touch $@

pmufw_clean:
	$(MAKE) -C $(PMUFW_LOC) clean
	@rm -f $(PMUFW_BIN)

pmufw_distclean:
	@rm -rf $(PMUFW_LOC) .pmufw_gen

#==========================================
# Device Tree Source and Blob compilation 
#==========================================
dt: $(DTB)

$(DTB): .dt_gen FORCE
	@mkdir -p $(O)
	$(EXPORT_DTC_PATH) && \
		cpp -I $(DT_LOC) -E -P -x assembler-with-cpp $(DTS) | \
		dtc -I dts -O dtb -o $@ -
	@cp $@ $(KERN_DTB)

.dt_gen:
	$(HSI) $(DT_HSI_FLAGS)
	@touch $@

dt_clean:
	@rm -f $(DTB) $(KERN_DTB)

dt_distclean:
	@rm -rf $(DT_LOC) .dt_gen $(KERN_DTB)

#==========================================
# BOOT.bin generation 
#==========================================
boot_bin: $(BOOT_BIN)

$(BOOT_BIN): $(BIF_FILE)
	@cd $(BOOT_BIN_LOC) && $(BOOT_GEN) $(BOOT_GEN_FLAGS)

$(BIF_FILE): FORCE
	@bash $(BIF_GEN) $(WITH_BIT) $(BIT_LOC) $(WITH_TOS)

boot_bin_distclean:
	@rm -rf $(BOOT_BIN_LOC)

