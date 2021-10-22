ZSBL_FPGA_LOC := ../fpga/design/$(FPGA_PRJ)/bootstrap

zsbl: FORCE
	$(EXPORT_CC_PATH) && \
		$(MAKE) -C ./zsbl \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		$(USER_FLAGS) $@
	@mkdir -p $(ZSBL_FPGA_LOC)/zsbl
	@cp zsbl/zsbl.bin $(ZSBL_FPGA_LOC)/zsbl/zsbl.bin

zsbl_clean zsbl_distclean:
	$(MAKE) -C ./zsbl $@
	@rm -rf $(ZSBL_FPGA_LOC)

