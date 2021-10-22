ifeq ($(ARCH),)
# ZynqMP BOOT.bin dependency
ifeq ($(obj-servefw),y)
# SERVE platform w/ servefw baremetal
BOOTBIN_DEP := servefw
ifeq ($(FPGA_ARCH),zynqmp)
BOOTBIN_DEP += pmufw
endif
else
# Ordinary Zynq/ZynqMP BOOT.bin
BOOTBIN_DEP := fsbl
ifeq ($(FPGA_ARCH),zynqmp)
BOOTBIN_DEP += pmufw atf
endif
BOOTBIN_DEP += uboot
endif
else
BOOTBIN_DEP := $(bootbin-prj-dep)  
endif

ifeq ($(ARCH),)
obj-bootbin-clean-y := $(foreach obj,$(BOOTBIN_DEP),$(obj)_clean)
obj-bootbin-dist-y := $(foreach obj,$(BOOTBIN_DEP),$(obj)_distclean)
endif

# BOOT.bin generation flags
ifeq ($(ARCH),)
bootbin-flag := BOOT_GEN=$(BOOT_GEN_BIN) \
	    SERVE_FW=$(obj-servefw) \
	    WITH_BIT=$(WITH_BIT) BIT_LOC=$(FPGA_TARGET) \
	    FPGA_ARCH=$(FPGA_ARCH) \
	    WITH_TOS=$(WITH_TOS) O=$(INSTALL_LOC)
else
bootbin-flag := O=$(INSTALL_LOC)/$(ARCH)
endif

# BOOT.bin generation
bootbin: $(BOOTBIN_DEP) FORCE
	@echo "Generating BOOT.bin image..."
	@mkdir -p $(INSTALL_LOC)/$(ARCH)
ifeq ($(ARCH),)
	$(MAKE) -C ./bootstrap $(bootbin-flag) boot_bin
endif
ifeq ($(ARCH),riscv)
	$(MAKE) $(bootbin-flag) $(bootbin-prj-flag) opensbi
endif

bootbin_clean: $(obj-bootbin-clean-y)
ifeq ($(ARCH),)
	@rm -f $(INSTALL_LOC)/BOOT.bin
endif
ifeq ($(ARCH),riscv)
	$(MAKE) $(bootbin-flag) opensbi_clean
endif

bootbin_distclean: $(obj-bootbin-dist-y)
ifeq ($(ARCH),)
	$(MAKE) -C ./bootstrap boot_bin_distclean
	@rm -rf $(INSTALL_LOC)/BOOT.bin
endif
ifeq ($(ARCH),riscv)
	$(MAKE) $(bootbin-flag) opensbi_distclean
endif

