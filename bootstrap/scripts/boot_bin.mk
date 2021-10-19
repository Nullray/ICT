BOOT_BIN_LOC := $(BOOT_STRAP_LOC)/boot_bin

BIF_GEN := $(BOOT_STRAP_LOC)/scripts/bif_gen.sh
BIF_FILE := $(BOOT_BIN_LOC)/boot_gen.bif

ifneq ($(O),)
BOOT_BIN := $(O)/$(OS)/BOOT.bin
endif
BOOT_BIN ?= $(BOOT_BIN_LOC)/BOOT.bin

BOOT_GEN_FLAGS := -arch zynqmp -w on \
	-image $(BIF_FILE) -log info -o $(BOOT_BIN)

#==========================================
# BOOT.bin generation 
#==========================================
boot_bin: $(BOOT_BIN)

$(BOOT_BIN): $(BIF_FILE)
	@cd $(BOOT_BIN_LOC) && $(BOOT_GEN) $(BOOT_GEN_FLAGS)

$(BIF_FILE): FORCE
	@bash $(BIF_GEN) $(FPGA_ARCH) $(WITH_BIT) $(BIT_LOC) $(WITH_TOS) $(SERVE_FW)

boot_bin_distclean:
	@rm -rf $(BOOT_BIN_LOC)

