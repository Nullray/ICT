
EXPORT_CC_PATH := export PATH=$(COMPILER_PATH):$$PATH

SDK_DIR := sdk
SDK_DIR_ABS := $(shell pwd)/$(SDK_DIR)

include keystone_app.mk

.PHONY: FORCE

all: $(obj-eapp-y) $(obj-host-y) $(obj-rt-y)

%.eapp: sdk FORCE
	@mkdir -p $(INSTALL_LOC)/$(patsubst %.eapp,%,$@)
	$(EXPORT_CC_PATH) && $(MAKE) -C $(patsubst %.eapp,%/eapp,$@) \
		KEYSTONE_SDK_DIR=$(SDK_DIR_ABS)
	@cp $(patsubst %.eapp,%,$@)/eapp/*.eapp_riscv \
		$(INSTALL_LOC)/$(patsubst %.eapp,%,$@)

%.host: sdk FORCE
	@mkdir -p $(INSTALL_LOC)/$(patsubst %.host,%,$@)
	$(EXPORT_CC_PATH) && $(MAKE) -C $(patsubst %.host,%/host,$@) \
		KEYSTONE_SDK_DIR=$(SDK_DIR_ABS)
	@cp $(patsubst %.host,%,$@)/host/*.riscv \
		$(INSTALL_LOC)/$(patsubst %.host,%,$@)

%.eyrie: sdk FORCE
	$(MAKE) -C eyrie clean \
		KEYSTONE_SDK_DIR=$(SDK_DIR_ABS)
	@mkdir -p $(INSTALL_LOC)/$(patsubst %.eyrie,%,$@)
	$(EXPORT_CC_PATH) && $(MAKE) -C eyrie \
		KEYSTONE_SDK_DIR=$(SDK_DIR_ABS) \
		OPTIONS_FLAGS="$($(patsubst %.eyrie,%,$(@F)).eyrie.opt)"
	@cp eyrie/eyrie-rt $(INSTALL_LOC)/$(patsubst %.eyrie,%,$@)

.PHONY: sdk
sdk:
	$(EXPORT_CC_PATH) && $(MAKE) -C $(SDK_DIR) 

clean: $(obj-eapp-clean-y) $(obj-host-clean-y) sdk_clean rt_clean
	@echo "All keystone application components are cleaned"

sdk_clean:
	$(MAKE) -C ./sdk clean

rt_clean: eyrie_clean
	@echo "Enclave run-time cleaned"

eyrie_clean:
	$(MAKE) -C eyrie clean \
		KEYSTONE_SDK_DIR=$(SDK_DIR_ABS)

%.eapp_clean:
	$(MAKE) -C $(patsubst %.eapp_clean,%/eapp,$@) clean

%.host_clean:
	$(MAKE) -C $(patsubst %.host_clean,%/host,$@) clean

