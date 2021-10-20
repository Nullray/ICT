DT_GEN := $(BOOT_STRAP_LOC)/dt-gen
ifeq ($(USER_DT_LOC),)
DT_LOC := $(BOOT_STRAP_LOC)/dt
else
DT_LOC := $(BOOT_STRAP_LOC)/$(ARCH)-dt
endif

DT_GEN_TCL := $(BOOT_STRAP_LOC)/scripts/dt.tcl

DT_HSI_FLAGS := $(HSI_FLAGS) -source $(DT_GEN_TCL) \
	-tclargs $(HDF_FILE) $(DT_LOC) $(DT_GEN)

ifeq ($(USER_DT_LOC),)
dts := system-top.dts
dtb := zynqmp.dtb
else
dts := $(USER_DT).dts
dtb := $(USER_DT).dtb
endif

DTS := $(DT_LOC)/$(dts)
DTB := $(DT_LOC)/$(dtb)

ifneq ($(O),)
KERN_DTB := $(O)/$(USER_DT)/$(dtb)
endif
KERN_DTB ?= $(DT_LOC)/$(dtb)

ifeq ($(USER_DT_LOC),)
obj-dt-dep := .dt_gen
else
obj-dt-dep := .dt_cp
endif

#==========================================
# Device Tree Source and Blob compilation 
#==========================================
dt: $(DTB)

$(DTB): $(obj-dt-dep) FORCE
ifeq ($(obj-dt-dep),.dt_gen)
ifneq ($(wildcard $(BOOT_STRAP_LOC)/dt-board/$(FPGA_BD).dtsi),)
	@cp $(BOOT_STRAP_LOC)/dt-board/$(FPGA_BD).dtsi $(DT_LOC)/board.dtsi
endif
ifneq ($(wildcard $(BOOT_STRAP_LOC)/dt-board/$(FPGA_BD)_top.dtsi),)
	@cp $(BOOT_STRAP_LOC)/dt-board/$(FPGA_BD)_top.dtsi $(DT_LOC)/board_top.dtsi
endif
ifneq ($(wildcard $(PS_DT)),)
	@cp $(PS_DT) $(DT_LOC)/design.dtsi
endif
ifneq ($(wildcard $(SYS_DT)),)
	@cp $(SYS_DT) $(DT_LOC)/design_top.dtsi
endif
ifneq ($(wildcard $(PL_DT)),)
	@cp $(PL_DT) $(DT_LOC)/pl.dtsi
endif
endif

ifeq ($(obj-dt-dep),.dt_cp)
ifneq ($(wildcard $(DT_LOC)/pcw_$(FPGA_BD).dtsi),)
	cp $(DT_LOC)/pcw_$(FPGA_BD).dtsi $(DT_LOC)/pcw.dtsi
endif
	cat $(DT_LOC)/vendor_$(VENDOR).dtsi
ifneq ($(wildcard $(DT_LOC)/vendor_$(VENDOR).dtsi),)
	cp $(DT_LOC)/vendor_$(VENDOR).dtsi $(DT_LOC)/vendor.dtsi
endif
endif
	@mkdir -p $(O)/$(USER_DT)
	$(EXPORT_DTC_PATH) && \
		cpp -I $(DT_LOC) -E -P -x assembler-with-cpp $(DTS) | \
		dtc -I dts -O dtb -o $@ -
	@cp $@ $(KERN_DTB)

.dt_gen:
	$(HSI) $(DT_HSI_FLAGS)
	@sed -i '13i #include \"board.dtsi\"' $(DTS)
ifneq ($(wildcard $(PS_DT)),)
	@sed -i '14i #include \"design.dtsi\"' $(DTS)
endif
ifneq ($(wildcard $(BOOT_STRAP_LOC)/dt-board/$(FPGA_BD)_top.dtsi),)
	@sed -i '$$i #include \"board_top.dtsi\"' $(DTS)
endif
ifneq ($(wildcard $(SYS_DT)),)
	@sed -i '$$i #include \"design_top.dtsi\"' $(DTS)
endif
	@touch $@

.dt_cp: 
	cp -r $(USER_DT_LOC) $(DT_LOC)
	@touch $@

dt_clean:
	@rm -f $(DTB) $(KERN_DTB)

dt_distclean:
	@rm -rf .dt_gen .dt_cp $(KERN_DTB) $(DTB)
	@rm -rf $(DT_LOC)

