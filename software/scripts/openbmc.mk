
OBMC_LOC=arm-openbmc

OBMC_BD=zcu102-zynqmp

# OpenBMC image
OBMC_IMG := $(OBMC_LOC)/*.rootfs.cpio.gz.u-boot

#==================================
# OpenBMC compilation
#==================================
openbmc: FORCE
	@bash scripts/openbmc.sh $(OBMC_BD) $(OBMC_LOC)
	@cp $(OBMC_IMG) $(INSTALL_LOC)/obmc.cpio.gz

openbmc_clean:
	@rm -f $(INSTALL_LOC)/obmc.cpio.gz

openbmc_distclean:
	@rm -rf arm-openbmc

