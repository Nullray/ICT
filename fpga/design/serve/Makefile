
.PHONY: FORCE

include default.mk

SERVE_DIR := pdk

ifeq ($(RV_TARGET),freedom)
FREEDOM_LOC := $(abspath ./$(SERVE_DIR)/hardware/freedom)
RV_HW_LOC := $(abspath $(FREEDOM_LOC)/builds/serve)
RV_RTL := $(RV_HW_LOC)/freedom.serve.i.v
endif

#==================================
# Target RISC-V core generation
#==================================
prj_hw: FORCE
	$(MAKE) -C $(SERVE_DIR) SERVE=i \
		RV_TARGET=$(RV_TARGET) $(RV_TARGET)
	@cp $(RV_RTL) sources/hdl/$(RV_TARGET)/$(RV_TARGET).v  

prj_hw_clean:
	$(MAKE) -C $(SERVE_DIR) SERVE=i \
		RV_TARGET=$(RV_TARGET) $(RV_TARGET)_clean
	@rm -f sources/hdl/freedom/freedom.v

#==================================
# Target RISC-V software generation 
#==================================
prj_sw: FORCE
	$(MAKE) -C $(SERVE_DIR) SERVE=i \
		TARGET_BD=$(FPGA_BD) \
		RV_TARGET=$(RV_TARGET) RV_HART_CNT=$(RV_HART_CNT) \
		$(PRJ_SW)

prj_sw_clean:
	$(MAKE) -C $(SERVE_DIR) SERVE=i \
		TARGET_BD=$(FPGA_BD) \
		RV_TARGET=$(RV_TARGET) RV_HART_CNT=$(RV_HART_CNT) \
		$(PRJ_SW)_clean

prj_sw_distclean:
	$(MAKE) -C $(SERVE_DIR) SERVE=i \
		TARGET_BD=$(FPGA_BD) \
		RV_TARGET=$(RV_TARGET) RV_HART_CNT=$(RV_HART_CNT) \
		$(PRJ_SW)_distclean

