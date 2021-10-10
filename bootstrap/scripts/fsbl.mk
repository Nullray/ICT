FSBL_LOC := $(BOOT_STRAP_LOC)/fsbl
FSBL_GEN_TCL := $(BOOT_STRAP_LOC)/scripts/fsbl.tcl

FSBL_HSI_FLAGS := $(HSI_FLAGS) -source $(FSBL_GEN_TCL) \
	-tclargs $(HDF_FILE) $(FSBL_LOC) $(FPGA_ARCH) $(FPGA_PROC)

FSBL_BIN_GEN := $(FSBL_LOC)/executable.elf
FSBL_BIN := $(FSBL_LOC)/bl2.elf

#==========================================
# Zynq/ZynqMP FSBL compilation 
#==========================================
fsbl: $(FSBL_BIN)

$(FSBL_BIN): .fsbl_gen FORCE
	$(EXPORT_CC_PATH) && $(MAKE) -C $(FSBL_LOC)
	@cp $(FSBL_BIN_GEN) $(FSBL_BIN)

.fsbl_gen:
	@$(HSI) $(FSBL_HSI_FLAGS)
ifneq ($(wildcard $(BOOT_STRAP_LOC)/fsbl-board/$(FPGA_BD).sh),)
	@bash $(BOOT_STRAP_LOC)/fsbl-board/$(FPGA_BD).sh $(FSBL_LOC)
endif
	@touch $@

fsbl_clean:
	$(MAKE) -C $(FSBL_LOC) clean
	@rm -f $(FSBL_BIN)

fsbl_distclean:
	@rm -rf $(FSBL_LOC) .fsbl_gen
