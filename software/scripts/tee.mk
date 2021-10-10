ifneq (${TOS},)
TEE_SRC := $(SW_LOC)/tee

obj-tos-y := $(foreach obj,$(TOS),$(obj).tos)
obj-tos-clean-y := $(foreach obj,$(TOS),$(obj).tos.clean)
obj-tos-dist-y := $(foreach obj,$(TOS),$(obj).tos.dist)

BL32_BIN := $(SW_LOC)/arm-tee/bl32.elf
endif

# OP-TEE compilation flags
optee-loc := $(SW_LOC)/arm-tee/optee
optee-obj-flags := PLATFORM=zynqmp \
	CFG_TEE_CORE_LOG_LEVEL=4 \
	CFG_TEE_TA_LOG_LEVEL=4 \
	CFG_ARM64_core=y \
	O=$(optee-loc)
optee-obj-clean := O=$(optee-loc)
optee-target := all
optee-obj := $(optee-loc)/core/tee.elf

#==================================
# TEE compilation 
#==================================
%.tos: FORCE
	$(EXPORT_CC_PATH) && $(MAKE) -C \
		$(TEE_SRC)/$(patsubst %.tos,%,$@) \
		$($(patsubst %.tos,%,$@)-obj-flags) \
		$($(patsubst %.tos,%,$@)-target)
	@cp $($(patsubst %.tos,%,$@)-obj) $(BL32_BIN)

%.tos.clean:
	$(MAKE) -C $($(patsubst %.tos.clean,%,$@)) \
		$($(patsubst %.tos.clean,%,$@)-obj-clean) clean
	@rm -f $(BL32_BIN)

%.tos.dist:
	@rm -rf $($(patsubst %.tos.dist,%,$@)-loc)

