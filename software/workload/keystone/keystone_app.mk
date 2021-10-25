# TODO: Please set your specified Keystone applications 
# in either obj-example-y or obj-app-y
obj-example-y := hello hello-native tests
obj-app-y :=

# TODO: Please specify runtime framework for various applications
# in either obj-example-rt-y or obj-app-rt-y
# format: <app name>.<runtime name>
obj-example-rt-y := hello.eyrie hello-native.eyrie tests.eyrie
obj-app-rt-y :=

# TODO: Please specify runtime framework compilation options for various applications
hello.eyrie.opt := -DUSE_FREEMEM -DENV_SETUP -DDEBUG \
	-DIO_SYSCALL_WRAPPING -DLINUX_SYSCALL_WRAPPING

hello-native.eyrie.opt := -DUSE_FREEMEM -DDEBUG

tests.eyrie.opt := -DUSE_FREEMEM -DDEBUG

# Generate compilation targets
obj-example-dir-y := $(foreach obj,$(obj-example-y),$(SDK_DIR)/examples/$(obj))
obj-app-dir-y := $(foreach obj,$(obj-app-y),apps/$(obj))

obj-eapp-y := $(foreach obj,$(obj-example-dir-y),$(obj).eapp)
obj-eapp-y += $(foreach obj,$(obj-app-dir-y),$(obj).eapp)

obj-eapp-clean-y := $(foreach obj,$(obj-example-dir-y),$(obj).eapp_clean)
obj-eapp-clean-y += $(foreach obj,$(obj-app-dir-y),$(obj).eapp_clean)

obj-host-y := $(foreach obj,$(obj-example-dir-y),$(obj).host)
obj-host-y += $(foreach obj,$(obj-app-dir-y),$(obj).host)

obj-host-clean-y := $(foreach obj,$(obj-example-dir-y),$(obj).host_clean)
obj-host-clean-y += $(foreach obj,$(obj-app-dir-y),$(obj).host_clean)

obj-rt-y := $(foreach obj,$(obj-example-rt-y),$(SDK_DIR)/examples/$(obj))
obj-rt-y += $(foreach obj,$(obj-app-rt-y),apps/$(obj))

