
EXPORT_CC_PATH := export PATH=$(COMPILER_PATH):$$PATH

obj-y := test
obj-fire-y := $(foreach obj,$(obj-y),$(obj).fire)
obj-clean-y := $(foreach obj,$(obj-y),$(obj).clean)

.PHONY: FORCE

all: $(obj-fire-y)

%.fire: FORCE 
	@mkdir -p $(INSTALL_LOC)/$(patsubst %.fire,%,$@)
	$(EXPORT_CC_PATH) && $(MAKE) -C $(patsubst %.fire,%,$@)
	@cp -r $(patsubst %.fire,%,$@)/bin \
		$(patsubst %.fire,%,$@)/elf \
		$(INSTALL_LOC)/$(patsubst %.fire,%,$@)

clean: $(obj-clean-y)

%.clean:
	$(MAKE) -C $(patsubst %.clean,%,$@) clean
	@rm -rf $(INSTALL_LOC)/$(patsubst %.clean,%,$@)

