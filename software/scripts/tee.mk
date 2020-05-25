
optee-loc := $(SW_LOC)/arm-tee/optee
optee-obj-flags := PLATFORM=zynqmp \
	CFG_TEE_CORE_LOG_LEVEL=4 \
	CFG_TEE_TA_LOG_LEVEL=4 \
	CFG_ARM64_core=y \
	O=$(optee-loc)
optee-obj-clean := O=$(optee-loc)
optee-target := all
optee-obj := $(optee-loc)/core/tee.elf 
