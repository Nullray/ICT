
XEN_PLAT := arm64
XEN_CROSS_COMPILE_FLAGS := XEN_TARGET_ARCH=$(XEN_PLAT) \
	CROSS_COMPILE=aarch64-linux-gnu-
XEN_TARGET := dist-xen

