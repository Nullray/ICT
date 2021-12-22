
EXPORT_CC_PATH := export PATH=$(COMPILER_PATH):$$PATH

# RISC-V benchmarks on FireSim emulator
obj-y := test
obj-fire-y := $(foreach obj,$(obj-y),$(obj).fire)
obj-clean-y := $(foreach obj,$(obj-y),$(obj).clean)

# Host tools on ARMv8 of Zynq MPSoC on NF card
obj-tool-y := host
obj-host-y := $(foreach obj,$(obj-tool-y),$(obj).host)
obj-host-clean-y := $(foreach obj,$(obj-y),$(obj).clean)

.PHONY: FORCE

ifeq ($(ARCH),riscv)
all: $(obj-fire-y)
else
all: $(obj-host-y)
endif

%.fire: FORCE 
	@mkdir -p $(INSTALL_LOC)/$(patsubst %.fire,%,$@)
	$(EXPORT_CC_PATH) && $(MAKE) -C $(patsubst %.fire,%,$@)
	@cp -r $(patsubst %.fire,%,$@)/bin \
		$(patsubst %.fire,%,$@)/elf \
		$(INSTALL_LOC)/$(patsubst %.fire,%,$@)

%.host: FORCE
	@mkdir -p $(INSTALL_LOC)/$(patsubst %.host,%,$@)
	$(EXPORT_CC_PATH) && $(MAKE) -C $(patsubst %.host,%,$@)
	@cp -r $(patsubst %.host,%,$@)/elf \
		$(INSTALL_LOC)/$(patsubst %.host,%,$@)

ifeq ($(ARCH),riscv)
clean: $(obj-clean-y)
else
clean: $(obj-host-clean-y)
endif

%.clean:
	$(MAKE) -C $(patsubst %.clean,%,$@) clean
	@rm -rf $(INSTALL_LOC)/$(patsubst %.clean,%,$@)

