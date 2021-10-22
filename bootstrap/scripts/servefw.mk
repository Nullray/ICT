# Zynq baremetal firmware for SERVE
servefw: FORCE
	$(EXPORT_CC_PATH) && \
		$(MAKE) -C servefw $(USER_FLAGS) all

servefw_clean servefw_distclean: FORCE
	@rm -f servefw/*.o servefw/*.d servefw/*.elf
