zsbl: FORCE
	$(EXPORT_CC_PATH) && \
		$(MAKE) -C ./zsbl \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		$(USER_FLAGS) $@

zsbl_clean zsbl_distclean:
	$(MAKE) -C ./zsbl $@

