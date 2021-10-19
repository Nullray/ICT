# OpenSBI related configurations
OPENSBI_SRC := $(SW_LOC)/opensbi/src
OPENSBI_LOC := $(SW_LOC)/riscv-opensbi

# OpenSBI cross compile flags
OPENSBI_COMPILE_FLAGS := O=$(OPENSBI_LOC) \
	CROSS_COMPILE=$(CROSS_COMPILE) \
	OPENSBI_PAYLOAD=$(UBOOT_BIN) \
	PLATFORM=$(PLATFORM) \
	$(USER_FLAGS)

RV_OPENSBI := $(OPENSBI_LOC)/platform/$(PLATFORM)/firmware/fw_payload.bin

ifneq ($(O),)
RV_BOOT_BIN := $(O)/RV_BOOT.bin
endif
RV_BOOT_BIN ?= $(abspath RV_BOOT.bin)

# RISC-V OpenSBI compilation
opensbi: FORCE 
	$(EXPORT_CC_PATH) && \
		$(MAKE) -C $(OPENSBI_SRC) \
		$(OPENSBI_COMPILE_FLAGS)
	@cp $(RV_OPENSBI) $(RV_BOOT_BIN)
	
opensbi_clean:
	$(EXPORT_CC_PATH) && \
		$(MAKE) -C $(OPENSBI_SRC) \
		$(OPENSBI_COMPILE_FLAGS) clean
	@rm -f $(RV_BOOT_BIN)

opensbi_distclean:
	@rm -rf $(OPENSBI_LOC) $(OPENSBI_LOC)-sm $(RV_BOOT_BIN)

