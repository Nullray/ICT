ATF_SRC := $(SW_LOC)/atf
ATF_LOC := $(SW_LOC)/arm-atf

# TODO: set your ATF compilation flags and targets
ATF_PLAT := zynqmp
ATF_CROSS_COMPILE_FLAGS := PLAT=$(ATF_PLAT) \
	RESET_TO_BL31=1 \
	CROSS_COMPILE=aarch64-linux-gnu- \
	LOG_LEVEL=20 \
	BUILD_BASE=$(ATF_LOC)
ATF_TARGET := bl31

ifneq (${TOS},)
ATF_CROSS_COMPILE_FLAGS += SPD=$(TOS)d
endif

ATF_ELF := $(ATF_LOC)/$(ATF_PLAT)/release/bl31/bl31.elf
BL31_BIN := $(ATF_LOC)/bl31.elf

#==================================
# ARM Trusted Firmware compilation 
#==================================
atf: $(obj-tos-y) FORCE
	$(EXPORT_CC_PATH) && $(MAKE) -C $(ATF_SRC) \
		$(ATF_CROSS_COMPILE_FLAGS) $(ATF_TARGET)
	@cp $(ATF_ELF) $(BL31_BIN)

atf_clean: $(obj-tos-clean-y)
	$(MAKE) -C $(ATF_SRC) BUILD_BASE=$(ATF_LOC) clean
	@rm -f $(BL31_BIN)

atf_distclean: $(obj-tos-dist-y)
	@rm -rf $(ATF_LOC)

