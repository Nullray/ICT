# Zynq baremetal firmware for SERVE
servefw: FORCE
	$(EXPORT_CC_PATH) && \
		$(MAKE) -C servefw \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		WITH_BIT=$(WITH_BIT) \
		FPGA_ARCH=$(FPGA_ARCH) \
		FPGA_PROC=$(FPGA_PROC) all

servefw_clean: FORCE
	@rm -f servefw/*.o servefw/*.d servefw/*.elf
