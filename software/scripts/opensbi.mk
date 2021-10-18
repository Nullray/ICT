# OpenSBI related configurations
OPENSBI_SRC := $(SW_LOC)/opensbi/src
OPENSBI_LOC := $(SW_LOC)/riscv-opensbi

# OpenSBI cross compile flags
OPENSBI_COMPILE_FLAGS := O=$(OPENSBI_LOC) \
	CROSS_COMPILE=$(CROSS_COMPILE) \
	OPENSBI_PAYLOAD=$(UBOOT_BIN) \
	PLATFORM=$(PLATFORM) \
	SERVE_PLAT=$(SERVE_PLAT) \
	HART_COUNT=$(HART_COUNT) \
	RV_TARGET=$(RV_TARGET) \
	WITH_SM=$(WITH_SM) \
	SM_ARM_ASSIST=$(SM_ARM_ASSIST)

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

