QEMU_SRC := $(SW_LOC)/qemu
QEMU_LOC := $(SW_LOC)/arm-qemu

QEMU_CONFIG_FLAGS := --prefix=/usr \
	--target-list=aarch64-softmmu \
	--enable-debug \
	--enable-kvm

#==================================
# QEMU native compilation
#==================================
qemu: $(QEMU_LOC)/.qemu.cfg FORCE
	$(MAKE) -C $(QEMU_LOC)

qemu_install: FORCE
	$(MAKE) -C $(QEMU_LOC) install

$(QEMU_LOC)/.qemu.cfg:
	@mkdir -p $(QEMU_LOC)
	@cd $(QEMU_LOC) && \
		$(QEMU_SRC)/configure $(QEMU_CONFIG_FLAGS)
	@touch $(QEMU_LOC)/.qemu.cfg

qemu_clean:
	$(MAKE) -C $(QEMU_LOC) clean 

qemu_distclean:
	@rm -rf $(QEMU_LOC)

