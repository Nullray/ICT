# TODO: set your ATF compilation flags and targets
ATF_PLAT := zynqmp
ATF_CROSS_COMPILE_FLAGS := PLAT=$(ATF_PLAT) \
	RESET_TO_BL31=1 \
	CROSS_COMPILE=aarch64-linux-gnu- \
	LOG_LEVEL=20
ATF_TARGET := bl31
