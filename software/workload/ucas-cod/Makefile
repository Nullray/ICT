
EXPORT_CC_PATH := export PATH=$(COMPILER_PATH):$$PATH

# MIPS 32 or RISC-V 32 benchmarks on simple CPU prototyping
obj-y := simple_test
obj-bench-y := $(foreach obj,$(obj-y),$(obj).bench)
obj-bench-clean-y := $(foreach obj,$(obj-y),$(obj).clean)

# Host tools on ARMv8 of Zynq MPSoC on NF card
obj-host-y := example reg_file alu simple_cpu
obj-tool-y := $(foreach obj,$(obj-host-y),$(obj).tool)
obj-tool-clean-y := $(foreach obj,$(obj-host-y),$(obj).toolclean)

.PHONY: FORCE

ifeq ($(ARCH),)
all: $(obj-tool-y)
else
all: $(obj-bench-y)
endif

%.bench: FORCE 
	@mkdir -p $(INSTALL_LOC)/$(patsubst %.bench,%,$@)
	$(EXPORT_CC_PATH) && $(MAKE) -C $(patsubst %.bench,%,$@) \
		$(WORKLOAD_FLAGS)
	@cp -r $(patsubst %.bench,%,$@)/bin \
		$(patsubst %.bench,%,$@)/elf \
		$(INSTALL_LOC)/$(patsubst %.bench,%,$@)

%.tool: FORCE
	@mkdir -p $(INSTALL_LOC)/$(patsubst %.tool,%,$@)

	$(EXPORT_CC_PATH) && $(MAKE) -C host/$(patsubst %.tool,%,$@) ROLE_ID=0
	$(MAKE) -C host/$(patsubst %.tool,%,$@) clean

	$(EXPORT_CC_PATH) && $(MAKE) -C host/$(patsubst %.tool,%,$@) ROLE_ID=1
	$(MAKE) -C host/$(patsubst %.tool,%,$@) clean

	$(EXPORT_CC_PATH) && $(MAKE) -C host/$(patsubst %.tool,%,$@) ROLE_ID=2
	$(MAKE) -C host/$(patsubst %.tool,%,$@) clean

	$(EXPORT_CC_PATH) && $(MAKE) -C host/$(patsubst %.tool,%,$@) ROLE_ID=3
	$(MAKE) -C host/$(patsubst %.tool,%,$@) clean

	$(EXPORT_CC_PATH) && $(MAKE) -C host/$(patsubst %.tool,%,$@) ROLE_ID=4
	$(MAKE) -C host/$(patsubst %.tool,%,$@) clean

	@cp -r host/$(patsubst %.tool,%,$@)/elf/* \
		$(INSTALL_LOC)/$(patsubst %.tool,%,$@)

ifeq ($(ARCH),)
clean: $(obj-tool-clean-y)
else
clean: $(obj-bench-clean-y)
endif

%.clean:
	$(MAKE) -C $(patsubst %.clean,%,$@) clean
	@rm -rf $(INSTALL_LOC)/$(patsubst %.clean,%,$@)

%.toolclean:
	$(MAKE) -C host/$(patsubst %.toolclean,%,$@) clean
	@rm -rf $(INSTALL_LOC)/$(patsubst %.toolclean,%,$@)

