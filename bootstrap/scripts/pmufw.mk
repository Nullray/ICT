PMUFW_LOC := $(BOOT_STRAP_LOC)/pmufw
PMUFW_GEN_TCL := $(BOOT_STRAP_LOC)/scripts/pmufw.tcl

PMUFW_HSI_FLAGS := $(HSI_FLAGS) -source $(PMUFW_GEN_TCL) \
	-tclargs $(HDF_FILE) $(PMUFW_LOC)

PMUFW_ELF_GEN := $(PMUFW_LOC)/executable.elf
PMUFW_ELF := $(PMUFW_LOC)/pmufw.elf

# Used for OpenBMC compilation
PMUFW_BIN := $(PMUFW_LOC)/pmu-zcu102-zynqmp.bin
PMUFW_OBJCOPY_FLAGS := -S -O binary --set-section-flags .bss=alloc,load,contents

#==========================================
# PMU Firware (PMUFW) compilation 
#==========================================
pmufw: $(PMUFW_ELF)

pmufw_bin: $(PMUFW_BIN)

$(PMUFW_BIN): $(PMUFW_ELF)
	$(EXPORT_CC_PATH) && mb-objcopy $(PMUFW_OBJCOPY_FLAGS) $< $@

$(PMUFW_ELF): .pmufw_gen FORCE
	$(EXPORT_CC_PATH) && $(MAKE) -C $(PMUFW_LOC)
	@cp $(PMUFW_ELF_GEN) $(PMUFW_ELF)

.pmufw_gen:
	@$(HSI) $(PMUFW_HSI_FLAGS)
	@touch $@

pmufw_clean:
	$(MAKE) -C $(PMUFW_LOC) clean
	@rm -f $(PMUFW_BIN)

pmufw_distclean:
	@rm -rf $(PMUFW_LOC) .pmufw_gen

