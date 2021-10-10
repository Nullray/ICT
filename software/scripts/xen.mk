XEN_SRC := $(SW_LOC)/xen
XEN_IMAGE := $(XEN_SRC)/xen/xen

XEN_PLAT := arm64
XEN_CROSS_COMPILE_FLAGS := XEN_TARGET_ARCH=$(XEN_PLAT) \
	CROSS_COMPILE=aarch64-linux-gnu- \
	CONFIG_DEBUG=y \
	CONFIG_EARLY_PRINTK=zynqmp

XEN_TARGET := dist-xen

ifneq (${INSTALL_LOC},)
XEN_INSTALL_LOC := $(INSTALL_LOC)
endif
XEN_INSTALL_LOC ?= $(KERN_LOC)

XEN_UIMAGE := $(XEN_INSTALL_LOC)/xen.ub

#==================================
# XEN compilation
#==================================
xen: $(XEN_IMAGE)
	$(UBOOT_LOC)/tools/mkimage -A arm64 -C none -T kernel \
		-a 6000000 -e 6000000 \
		-n "xen.ub" -d $(XEN_IMAGE) $(XEN_UIMAGE)

$(XEN_IMAGE): FORCE 
	$(EXPORT_CC_PATH) && $(MAKE) -C $(XEN_SRC) \
		$(XEN_CROSS_COMPILE_FLAGS) $(XEN_TARGET) -j 10

xen_clean:
	$(MAKE) -C $(XEN_SRC) clean-xen 

xen_distclean:
	$(MAKE) -C $(XEN_SRC) distclean-xen

