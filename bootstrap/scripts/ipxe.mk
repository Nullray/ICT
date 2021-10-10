IPXE_TARGET := bin-arm64-efi

IPXE_TARGET_LOC := $(abspath $(BOOT_STRAP_LOC)/ipxe/src/$(IPXE_TARGET))

#==========================================
# iPXE cross generation 
#==========================================
ipxe: .ipxe_pre FORCE
ifneq ($(TARGET_IQN),)
	@bash scripts/ipxe_iqn_gen.sh $(TARGET_IQN)
else
	@bash scripts/ipxe_ironic_gen.sh $(TFTP_SERVER) 
endif
	$(EXPORT_CC_PATH) && \
		$(MAKE) -C ipxe/src \
		CROSS_COMPILE=aarch64-linux-gnu- \
		EMBED=$(IPXE_TARGET_LOC)/ipxe_script \
		$(IPXE_TARGET)/snp.efi -j 10
	@cp $(IPXE_TARGET_LOC)/snp.efi $(INSTALL_LOC)

.ipxe_pre:
	$(EXPORT_CC_PATH) && \
		$(MAKE) -C ipxe/src \
		CROSS_COMPILE=aarch64-linux-gnu- \
		$(IPXE_TARGET)/snp.efi -j 10
	@cp src/ipxe/* ipxe/src/config/local
	@touch $@

ipxe_clean:
		$(MAKE) -C ipxe/src $(IPXE_TARGET) clean

ipxe_distclean:
		$(MAKE) -C ipxe/src $(IPXE_TARGET) veryclean
		$(MAKE) -C ipxe/src bin veryclean
		@rm -f .ipxe_pre

