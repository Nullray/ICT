
# OpenBMC image
OBMC_IMG := *.rootfs.cpio.gz.u-boot

#==================================
# OpenBMC compilation
#==================================
openbmc: FORCE
	@bash scripts/openbmc.sh $(OBMC_BD) $(OBMC_LOC)
	@cd $(OBMC_LOC)/$(OBMC_IMG_LOC)/ && \
		cp $(OBMC_IMG) $(INSTALL_LOC)/obmc.cpio.gz && cd -

openbmc_clean:
	@rm -f $(INSTALL_LOC)/obmc.cpio.gz

openbmc_distclean:
	@rm -rf arm-openbmc

