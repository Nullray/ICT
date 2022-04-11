SIM_TOP := get_trace

#BENCH_SUITE=basic..., DUT_ARCH=single_cycle:multi_cycle:turbo, DUT_ISA=mips:riscv32
SIM_TARGET := custom_cpu
DUT_ARCH := multi_cycle
DUT_ISA := riscv32

SIM_SRC_LOC := ../../../../fpga/design/ucas-cod/hardware/sim
SIM_OBJ_LOC := sim_out

SIM_BIN := $(SIM_OBJ_LOC)/sim.vvp
SIM_DUMP := $(SIM_OBJ_LOC)/dump.fst

SIM_SRCS := $(wildcard $(SIM_SRC_LOC)/../wrapper/$(SIM_TARGET)/*.v)
SIM_SRCS += $(wildcard $(SIM_SRC_LOC)/$(SIM_TARGET)/$(DUT_ARCH)/cpu_test_top_golden.v)
SIM_SRCS += $(wildcard $(SIM_SRC_LOC)/$(SIM_TARGET)/$(DUT_ARCH)/golden/$(DUT_ISA)/*.v)
SIM_SRCS += $(wildcard $(SIM_SRC_LOC)/$(SIM_TARGET)/common/*.v)
SIM_SRCS += get_trace.v

BENCH_LOC := ../benchmark/simple_test/$(BENCH_SUITE)/$(DUT_ISA)
MEM_FILE := $(BENCH_LOC)/sim/$(BENCH).mem
TRACE_FILE := $(BENCH_LOC)/trace/$(BENCH).trace

IV_FLAGS := -I $(SIM_SRC_LOC)/$(SIM_TARGET)			#SIM_TARGET=custom_cpu:simple_cpu
IV_FLAGS += -DTRACE_FILE=\"$(TRACE_FILE)\"

# Use FST format for waveform to provide better compression ratio
# Waveform file size would be reduced by about 10x.
PLUSARGS += -fst
PLUSARGS += +INITMEM="$(MEM_FILE)"

bhv_sim:
	@mkdir -p $(SIM_OBJ_LOC)
	@mkdir -p $(BENCH_LOC)/trace
	iverilog -o $(SIM_BIN) -s $(SIM_TOP) $(IV_FLAGS) $(SIM_SRCS)
	$(SIM_BIN) +DUMP="$(SIM_DUMP)" $(PLUSARGS)
