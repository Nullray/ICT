#ifndef __FIRESIM_H
#define __FIRESIM_H
#include <stdint.h>
#include <stdbool.h>
static const char* const TARGET_NAME = R"ESC(FireSim)ESC";
#define PLATFORM_TYPE Vfiresim_top
#define data_t uint32_t

// Widget: SimulationMaster_0
#define SIMULATIONMASTER_0(x) SIMULATIONMASTER_0_ ## x
#ifndef SIMULATIONMASTER_struct_guard
#define SIMULATIONMASTER_struct_guard
typedef struct SIMULATIONMASTER_struct {
    unsigned long STEP;
    unsigned long DONE;
    unsigned long INIT_DONE;
} SIMULATIONMASTER_struct;
#endif // SIMULATIONMASTER_struct_guard

#define SIMULATIONMASTER_0_PRESENT
#define SIMULATIONMASTER_0_substruct_create \
SIMULATIONMASTER_struct * SIMULATIONMASTER_0_substruct = (SIMULATIONMASTER_struct *) malloc(sizeof(SIMULATIONMASTER_struct)); \
SIMULATIONMASTER_0_substruct->STEP = 144; \
SIMULATIONMASTER_0_substruct->DONE = 145; \
SIMULATIONMASTER_0_substruct->INIT_DONE = 146; \

const static uint32_t SIMULATIONMASTER_0_R_num_registers = 2;
static const char* const SIMULATIONMASTER_0_R_names [2] = {
  R"ESC(DONE)ESC",
  R"ESC(INIT_DONE)ESC"
};
static uint32_t SIMULATIONMASTER_0_R_addrs [2] = {
  145,
  146
};
const static uint32_t SIMULATIONMASTER_0_W_num_registers = 3;
static const char* const SIMULATIONMASTER_0_W_names [3] = {
  R"ESC(STEP)ESC",
  R"ESC(DONE)ESC",
  R"ESC(INIT_DONE)ESC"
};
static uint32_t SIMULATIONMASTER_0_W_addrs [3] = {
  144,
  145,
  146
};

// Widget: PeekPokeBridgeModule_0
#define PEEKPOKEBRIDGEMODULE_0(x) PEEKPOKEBRIDGEMODULE_0_ ## x
#ifndef PEEKPOKEBRIDGEMODULE_struct_guard
#define PEEKPOKEBRIDGEMODULE_struct_guard
typedef struct PEEKPOKEBRIDGEMODULE_struct {
    unsigned long tCycle_0;
    unsigned long tCycle_1;
    unsigned long tCycle_latch;
    unsigned long reset_0;
    unsigned long PRECISE_PEEKABLE;
    unsigned long READY;
} PEEKPOKEBRIDGEMODULE_struct;
#endif // PEEKPOKEBRIDGEMODULE_struct_guard

#define PEEKPOKEBRIDGEMODULE_0_PRESENT
#define PEEKPOKEBRIDGEMODULE_0_substruct_create \
PEEKPOKEBRIDGEMODULE_struct * PEEKPOKEBRIDGEMODULE_0_substruct = (PEEKPOKEBRIDGEMODULE_struct *) malloc(sizeof(PEEKPOKEBRIDGEMODULE_struct)); \
PEEKPOKEBRIDGEMODULE_0_substruct->tCycle_0 = 128; \
PEEKPOKEBRIDGEMODULE_0_substruct->tCycle_1 = 129; \
PEEKPOKEBRIDGEMODULE_0_substruct->tCycle_latch = 130; \
PEEKPOKEBRIDGEMODULE_0_substruct->reset_0 = 131; \
PEEKPOKEBRIDGEMODULE_0_substruct->PRECISE_PEEKABLE = 132; \
PEEKPOKEBRIDGEMODULE_0_substruct->READY = 133; \

const static uint32_t PEEKPOKEBRIDGEMODULE_0_R_num_registers = 5;
static const char* const PEEKPOKEBRIDGEMODULE_0_R_names [5] = {
  R"ESC(tCycle_0)ESC",
  R"ESC(tCycle_1)ESC",
  R"ESC(reset_0)ESC",
  R"ESC(PRECISE_PEEKABLE)ESC",
  R"ESC(READY)ESC"
};
static uint32_t PEEKPOKEBRIDGEMODULE_0_R_addrs [5] = {
  128,
  129,
  131,
  132,
  133
};
const static uint32_t PEEKPOKEBRIDGEMODULE_0_W_num_registers = 4;
static const char* const PEEKPOKEBRIDGEMODULE_0_W_names [4] = {
  R"ESC(tCycle_latch)ESC",
  R"ESC(reset_0)ESC",
  R"ESC(PRECISE_PEEKABLE)ESC",
  R"ESC(READY)ESC"
};
static uint32_t PEEKPOKEBRIDGEMODULE_0_W_addrs [4] = {
  130,
  131,
  132,
  133
};
// Pokeable target inputs
#define POKE_SIZE 1ULL
const static uint32_t reset = 0;
static uint32_t INPUT_ADDRS [1] = {
  131
};
static const char* const INPUT_NAMES [1] = {
  R"ESC(reset)ESC"
};
static uint32_t INPUT_CHUNKS [1] = {
  1
};
// Peekable target outputs
#define PEEK_SIZE 0ULL
static const void* const OUTPUT_ADDRS [1] = {

};
static const void* const OUTPUT_NAMES [1] = {

};
static const void* const OUTPUT_CHUNKS [1] = {

};

// Widget: SerialBridgeModule_0
#define SERIALBRIDGEMODULE_0(x) SERIALBRIDGEMODULE_0_ ## x
#ifndef SERIALBRIDGEMODULE_struct_guard
#define SERIALBRIDGEMODULE_struct_guard
typedef struct SERIALBRIDGEMODULE_struct {
    unsigned long in_bits;
    unsigned long in_valid;
    unsigned long in_ready;
    unsigned long out_bits;
    unsigned long out_valid;
    unsigned long out_ready;
    unsigned long step_size;
    unsigned long done;
    unsigned long start;
} SERIALBRIDGEMODULE_struct;
#endif // SERIALBRIDGEMODULE_struct_guard

#define SERIALBRIDGEMODULE_0_PRESENT
#define SERIALBRIDGEMODULE_0_substruct_create \
SERIALBRIDGEMODULE_struct * SERIALBRIDGEMODULE_0_substruct = (SERIALBRIDGEMODULE_struct *) malloc(sizeof(SERIALBRIDGEMODULE_struct)); \
SERIALBRIDGEMODULE_0_substruct->in_bits = 96; \
SERIALBRIDGEMODULE_0_substruct->in_valid = 97; \
SERIALBRIDGEMODULE_0_substruct->in_ready = 98; \
SERIALBRIDGEMODULE_0_substruct->out_bits = 99; \
SERIALBRIDGEMODULE_0_substruct->out_valid = 100; \
SERIALBRIDGEMODULE_0_substruct->out_ready = 101; \
SERIALBRIDGEMODULE_0_substruct->step_size = 102; \
SERIALBRIDGEMODULE_0_substruct->done = 103; \
SERIALBRIDGEMODULE_0_substruct->start = 104; \

const static uint32_t SERIALBRIDGEMODULE_0_R_num_registers = 9;
static const char* const SERIALBRIDGEMODULE_0_R_names [9] = {
  R"ESC(in_bits)ESC",
  R"ESC(in_valid)ESC",
  R"ESC(in_ready)ESC",
  R"ESC(out_bits)ESC",
  R"ESC(out_valid)ESC",
  R"ESC(out_ready)ESC",
  R"ESC(step_size)ESC",
  R"ESC(done)ESC",
  R"ESC(start)ESC"
};
static uint32_t SERIALBRIDGEMODULE_0_R_addrs [9] = {
  96,
  97,
  98,
  99,
  100,
  101,
  102,
  103,
  104
};
const static uint32_t SERIALBRIDGEMODULE_0_W_num_registers = 9;
static const char* const SERIALBRIDGEMODULE_0_W_names [9] = {
  R"ESC(in_bits)ESC",
  R"ESC(in_valid)ESC",
  R"ESC(in_ready)ESC",
  R"ESC(out_bits)ESC",
  R"ESC(out_valid)ESC",
  R"ESC(out_ready)ESC",
  R"ESC(step_size)ESC",
  R"ESC(done)ESC",
  R"ESC(start)ESC"
};
static uint32_t SERIALBRIDGEMODULE_0_W_addrs [9] = {
  96,
  97,
  98,
  99,
  100,
  101,
  102,
  103,
  104
};
#define SERIALBRIDGEMODULE_0_has_memory true
#define SERIALBRIDGEMODULE_0_memory_offset MainMemory_0_offset

// Widget: FASEDMemoryTimingModel_0
#define FASEDMEMORYTIMINGMODEL_0(x) FASEDMEMORYTIMINGMODEL_0_ ## x
#ifndef FASEDMEMORYTIMINGMODEL_struct_guard
#define FASEDMEMORYTIMINGMODEL_struct_guard
typedef struct FASEDMEMORYTIMINGMODEL_struct {
    unsigned long writeLatency;
    unsigned long readLatency;
    unsigned long writeMaxReqs;
    unsigned long readMaxReqs;
    unsigned long writeOutstandingHistogram_0;
    unsigned long writeOutstandingHistogram_1;
    unsigned long writeOutstandingHistogram_2;
    unsigned long writeOutstandingHistogram_3;
    unsigned long writeOutstandingHistogram_4;
    unsigned long readOutstandingHistogram_0;
    unsigned long readOutstandingHistogram_1;
    unsigned long readOutstandingHistogram_2;
    unsigned long readOutstandingHistogram_3;
    unsigned long readOutstandingHistogram_4;
    unsigned long totalWriteBeats;
    unsigned long totalReadBeats;
    unsigned long totalWrites;
    unsigned long totalReads;
    unsigned long relaxFunctionalModel;
    unsigned long rrespError;
    unsigned long brespError;
} FASEDMEMORYTIMINGMODEL_struct;
#endif // FASEDMEMORYTIMINGMODEL_struct_guard

#define FASEDMEMORYTIMINGMODEL_0_PRESENT
#define FASEDMEMORYTIMINGMODEL_0_substruct_create \
FASEDMEMORYTIMINGMODEL_struct * FASEDMEMORYTIMINGMODEL_0_substruct = (FASEDMEMORYTIMINGMODEL_struct *) malloc(sizeof(FASEDMEMORYTIMINGMODEL_struct)); \
FASEDMEMORYTIMINGMODEL_0_substruct->writeLatency = 0; \
FASEDMEMORYTIMINGMODEL_0_substruct->readLatency = 1; \
FASEDMEMORYTIMINGMODEL_0_substruct->writeMaxReqs = 2; \
FASEDMEMORYTIMINGMODEL_0_substruct->readMaxReqs = 3; \
FASEDMEMORYTIMINGMODEL_0_substruct->writeOutstandingHistogram_0 = 4; \
FASEDMEMORYTIMINGMODEL_0_substruct->writeOutstandingHistogram_1 = 5; \
FASEDMEMORYTIMINGMODEL_0_substruct->writeOutstandingHistogram_2 = 6; \
FASEDMEMORYTIMINGMODEL_0_substruct->writeOutstandingHistogram_3 = 7; \
FASEDMEMORYTIMINGMODEL_0_substruct->writeOutstandingHistogram_4 = 8; \
FASEDMEMORYTIMINGMODEL_0_substruct->readOutstandingHistogram_0 = 9; \
FASEDMEMORYTIMINGMODEL_0_substruct->readOutstandingHistogram_1 = 10; \
FASEDMEMORYTIMINGMODEL_0_substruct->readOutstandingHistogram_2 = 11; \
FASEDMEMORYTIMINGMODEL_0_substruct->readOutstandingHistogram_3 = 12; \
FASEDMEMORYTIMINGMODEL_0_substruct->readOutstandingHistogram_4 = 13; \
FASEDMEMORYTIMINGMODEL_0_substruct->totalWriteBeats = 14; \
FASEDMEMORYTIMINGMODEL_0_substruct->totalReadBeats = 15; \
FASEDMEMORYTIMINGMODEL_0_substruct->totalWrites = 16; \
FASEDMEMORYTIMINGMODEL_0_substruct->totalReads = 17; \
FASEDMEMORYTIMINGMODEL_0_substruct->relaxFunctionalModel = 18; \
FASEDMEMORYTIMINGMODEL_0_substruct->rrespError = 19; \
FASEDMEMORYTIMINGMODEL_0_substruct->brespError = 20; \

const static uint32_t FASEDMEMORYTIMINGMODEL_0_R_num_registers = 21;
static const char* const FASEDMEMORYTIMINGMODEL_0_R_names [21] = {
  R"ESC(writeLatency)ESC",
  R"ESC(readLatency)ESC",
  R"ESC(writeMaxReqs)ESC",
  R"ESC(readMaxReqs)ESC",
  R"ESC(writeOutstandingHistogram_0)ESC",
  R"ESC(writeOutstandingHistogram_1)ESC",
  R"ESC(writeOutstandingHistogram_2)ESC",
  R"ESC(writeOutstandingHistogram_3)ESC",
  R"ESC(writeOutstandingHistogram_4)ESC",
  R"ESC(readOutstandingHistogram_0)ESC",
  R"ESC(readOutstandingHistogram_1)ESC",
  R"ESC(readOutstandingHistogram_2)ESC",
  R"ESC(readOutstandingHistogram_3)ESC",
  R"ESC(readOutstandingHistogram_4)ESC",
  R"ESC(totalWriteBeats)ESC",
  R"ESC(totalReadBeats)ESC",
  R"ESC(totalWrites)ESC",
  R"ESC(totalReads)ESC",
  R"ESC(relaxFunctionalModel)ESC",
  R"ESC(rrespError)ESC",
  R"ESC(brespError)ESC"
};
static uint32_t FASEDMEMORYTIMINGMODEL_0_R_addrs [21] = {
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  16,
  17,
  18,
  19,
  20
};
const static uint32_t FASEDMEMORYTIMINGMODEL_0_W_num_registers = 5;
static const char* const FASEDMEMORYTIMINGMODEL_0_W_names [5] = {
  R"ESC(writeLatency)ESC",
  R"ESC(readLatency)ESC",
  R"ESC(writeMaxReqs)ESC",
  R"ESC(readMaxReqs)ESC",
  R"ESC(relaxFunctionalModel)ESC"
};
static uint32_t FASEDMEMORYTIMINGMODEL_0_W_addrs [5] = {
  0,
  1,
  2,
  3,
  18
};
#define FASEDMEMORYTIMINGMODEL_0_target_addr_bits 31

// Widget: FASEDMemoryTimingModel_1
#define FASEDMEMORYTIMINGMODEL_1(x) FASEDMEMORYTIMINGMODEL_1_ ## x
#ifndef FASEDMEMORYTIMINGMODEL_struct_guard
#define FASEDMEMORYTIMINGMODEL_struct_guard
typedef struct FASEDMEMORYTIMINGMODEL_struct {
    unsigned long writeLatency;
    unsigned long readLatency;
    unsigned long writeMaxReqs;
    unsigned long readMaxReqs;
    unsigned long writeOutstandingHistogram_0;
    unsigned long writeOutstandingHistogram_1;
    unsigned long writeOutstandingHistogram_2;
    unsigned long writeOutstandingHistogram_3;
    unsigned long writeOutstandingHistogram_4;
    unsigned long readOutstandingHistogram_0;
    unsigned long readOutstandingHistogram_1;
    unsigned long readOutstandingHistogram_2;
    unsigned long readOutstandingHistogram_3;
    unsigned long readOutstandingHistogram_4;
    unsigned long totalWriteBeats;
    unsigned long totalReadBeats;
    unsigned long totalWrites;
    unsigned long totalReads;
    unsigned long relaxFunctionalModel;
    unsigned long rrespError;
    unsigned long brespError;
} FASEDMEMORYTIMINGMODEL_struct;
#endif // FASEDMEMORYTIMINGMODEL_struct_guard

#define FASEDMEMORYTIMINGMODEL_1_PRESENT
#define FASEDMEMORYTIMINGMODEL_1_substruct_create \
FASEDMEMORYTIMINGMODEL_struct * FASEDMEMORYTIMINGMODEL_1_substruct = (FASEDMEMORYTIMINGMODEL_struct *) malloc(sizeof(FASEDMEMORYTIMINGMODEL_struct)); \
FASEDMEMORYTIMINGMODEL_1_substruct->writeLatency = 32; \
FASEDMEMORYTIMINGMODEL_1_substruct->readLatency = 33; \
FASEDMEMORYTIMINGMODEL_1_substruct->writeMaxReqs = 34; \
FASEDMEMORYTIMINGMODEL_1_substruct->readMaxReqs = 35; \
FASEDMEMORYTIMINGMODEL_1_substruct->writeOutstandingHistogram_0 = 36; \
FASEDMEMORYTIMINGMODEL_1_substruct->writeOutstandingHistogram_1 = 37; \
FASEDMEMORYTIMINGMODEL_1_substruct->writeOutstandingHistogram_2 = 38; \
FASEDMEMORYTIMINGMODEL_1_substruct->writeOutstandingHistogram_3 = 39; \
FASEDMEMORYTIMINGMODEL_1_substruct->writeOutstandingHistogram_4 = 40; \
FASEDMEMORYTIMINGMODEL_1_substruct->readOutstandingHistogram_0 = 41; \
FASEDMEMORYTIMINGMODEL_1_substruct->readOutstandingHistogram_1 = 42; \
FASEDMEMORYTIMINGMODEL_1_substruct->readOutstandingHistogram_2 = 43; \
FASEDMEMORYTIMINGMODEL_1_substruct->readOutstandingHistogram_3 = 44; \
FASEDMEMORYTIMINGMODEL_1_substruct->readOutstandingHistogram_4 = 45; \
FASEDMEMORYTIMINGMODEL_1_substruct->totalWriteBeats = 46; \
FASEDMEMORYTIMINGMODEL_1_substruct->totalReadBeats = 47; \
FASEDMEMORYTIMINGMODEL_1_substruct->totalWrites = 48; \
FASEDMEMORYTIMINGMODEL_1_substruct->totalReads = 49; \
FASEDMEMORYTIMINGMODEL_1_substruct->relaxFunctionalModel = 50; \
FASEDMEMORYTIMINGMODEL_1_substruct->rrespError = 51; \
FASEDMEMORYTIMINGMODEL_1_substruct->brespError = 52; \

const static uint32_t FASEDMEMORYTIMINGMODEL_1_R_num_registers = 21;
static const char* const FASEDMEMORYTIMINGMODEL_1_R_names [21] = {
  R"ESC(writeLatency)ESC",
  R"ESC(readLatency)ESC",
  R"ESC(writeMaxReqs)ESC",
  R"ESC(readMaxReqs)ESC",
  R"ESC(writeOutstandingHistogram_0)ESC",
  R"ESC(writeOutstandingHistogram_1)ESC",
  R"ESC(writeOutstandingHistogram_2)ESC",
  R"ESC(writeOutstandingHistogram_3)ESC",
  R"ESC(writeOutstandingHistogram_4)ESC",
  R"ESC(readOutstandingHistogram_0)ESC",
  R"ESC(readOutstandingHistogram_1)ESC",
  R"ESC(readOutstandingHistogram_2)ESC",
  R"ESC(readOutstandingHistogram_3)ESC",
  R"ESC(readOutstandingHistogram_4)ESC",
  R"ESC(totalWriteBeats)ESC",
  R"ESC(totalReadBeats)ESC",
  R"ESC(totalWrites)ESC",
  R"ESC(totalReads)ESC",
  R"ESC(relaxFunctionalModel)ESC",
  R"ESC(rrespError)ESC",
  R"ESC(brespError)ESC"
};
static uint32_t FASEDMEMORYTIMINGMODEL_1_R_addrs [21] = {
  32,
  33,
  34,
  35,
  36,
  37,
  38,
  39,
  40,
  41,
  42,
  43,
  44,
  45,
  46,
  47,
  48,
  49,
  50,
  51,
  52
};
const static uint32_t FASEDMEMORYTIMINGMODEL_1_W_num_registers = 5;
static const char* const FASEDMEMORYTIMINGMODEL_1_W_names [5] = {
  R"ESC(writeLatency)ESC",
  R"ESC(readLatency)ESC",
  R"ESC(writeMaxReqs)ESC",
  R"ESC(readMaxReqs)ESC",
  R"ESC(relaxFunctionalModel)ESC"
};
static uint32_t FASEDMEMORYTIMINGMODEL_1_W_addrs [5] = {
  32,
  33,
  34,
  35,
  50
};
#define FASEDMEMORYTIMINGMODEL_1_target_addr_bits 35

// Widget: BlockDevBridgeModule_0
#define BLOCKDEVBRIDGEMODULE_0(x) BLOCKDEVBRIDGEMODULE_0_ ## x
#ifndef BLOCKDEVBRIDGEMODULE_struct_guard
#define BLOCKDEVBRIDGEMODULE_struct_guard
typedef struct BLOCKDEVBRIDGEMODULE_struct {
    unsigned long read_latency;
    unsigned long write_latency;
    unsigned long bdev_nsectors;
    unsigned long bdev_max_req_len;
    unsigned long bdev_req_valid;
    unsigned long bdev_req_write;
    unsigned long bdev_req_offset;
    unsigned long bdev_req_len;
    unsigned long bdev_req_tag;
    unsigned long bdev_req_ready;
    unsigned long bdev_data_valid;
    unsigned long bdev_data_data_upper;
    unsigned long bdev_data_data_lower;
    unsigned long bdev_data_tag;
    unsigned long bdev_data_ready;
    unsigned long bdev_rresp_data_upper;
    unsigned long bdev_rresp_data_lower;
    unsigned long bdev_rresp_tag;
    unsigned long bdev_rresp_valid;
    unsigned long bdev_rresp_ready;
    unsigned long bdev_wack_tag;
    unsigned long bdev_wack_valid;
    unsigned long bdev_wack_ready;
    unsigned long bdev_reqs_pending;
    unsigned long bdev_wack_stalled;
    unsigned long bdev_rresp_stalled;
} BLOCKDEVBRIDGEMODULE_struct;
#endif // BLOCKDEVBRIDGEMODULE_struct_guard

#define BLOCKDEVBRIDGEMODULE_0_PRESENT
#define BLOCKDEVBRIDGEMODULE_0_substruct_create \
BLOCKDEVBRIDGEMODULE_struct * BLOCKDEVBRIDGEMODULE_0_substruct = (BLOCKDEVBRIDGEMODULE_struct *) malloc(sizeof(BLOCKDEVBRIDGEMODULE_struct)); \
BLOCKDEVBRIDGEMODULE_0_substruct->read_latency = 64; \
BLOCKDEVBRIDGEMODULE_0_substruct->write_latency = 65; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_nsectors = 66; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_max_req_len = 67; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_req_valid = 68; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_req_write = 69; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_req_offset = 70; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_req_len = 71; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_req_tag = 72; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_req_ready = 73; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_data_valid = 74; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_data_data_upper = 75; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_data_data_lower = 76; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_data_tag = 77; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_data_ready = 78; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_rresp_data_upper = 79; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_rresp_data_lower = 80; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_rresp_tag = 81; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_rresp_valid = 82; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_rresp_ready = 83; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_wack_tag = 84; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_wack_valid = 85; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_wack_ready = 86; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_reqs_pending = 87; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_wack_stalled = 88; \
BLOCKDEVBRIDGEMODULE_0_substruct->bdev_rresp_stalled = 89; \

const static uint32_t BLOCKDEVBRIDGEMODULE_0_R_num_registers = 24;
static const char* const BLOCKDEVBRIDGEMODULE_0_R_names [24] = {
  R"ESC(read_latency)ESC",
  R"ESC(write_latency)ESC",
  R"ESC(bdev_req_valid)ESC",
  R"ESC(bdev_req_write)ESC",
  R"ESC(bdev_req_offset)ESC",
  R"ESC(bdev_req_len)ESC",
  R"ESC(bdev_req_tag)ESC",
  R"ESC(bdev_req_ready)ESC",
  R"ESC(bdev_data_valid)ESC",
  R"ESC(bdev_data_data_upper)ESC",
  R"ESC(bdev_data_data_lower)ESC",
  R"ESC(bdev_data_tag)ESC",
  R"ESC(bdev_data_ready)ESC",
  R"ESC(bdev_rresp_data_upper)ESC",
  R"ESC(bdev_rresp_data_lower)ESC",
  R"ESC(bdev_rresp_tag)ESC",
  R"ESC(bdev_rresp_valid)ESC",
  R"ESC(bdev_rresp_ready)ESC",
  R"ESC(bdev_wack_tag)ESC",
  R"ESC(bdev_wack_valid)ESC",
  R"ESC(bdev_wack_ready)ESC",
  R"ESC(bdev_reqs_pending)ESC",
  R"ESC(bdev_wack_stalled)ESC",
  R"ESC(bdev_rresp_stalled)ESC"
};
static uint32_t BLOCKDEVBRIDGEMODULE_0_R_addrs [24] = {
  64,
  65,
  68,
  69,
  70,
  71,
  72,
  73,
  74,
  75,
  76,
  77,
  78,
  79,
  80,
  81,
  82,
  83,
  84,
  85,
  86,
  87,
  88,
  89
};
const static uint32_t BLOCKDEVBRIDGEMODULE_0_W_num_registers = 26;
static const char* const BLOCKDEVBRIDGEMODULE_0_W_names [26] = {
  R"ESC(read_latency)ESC",
  R"ESC(write_latency)ESC",
  R"ESC(bdev_nsectors)ESC",
  R"ESC(bdev_max_req_len)ESC",
  R"ESC(bdev_req_valid)ESC",
  R"ESC(bdev_req_write)ESC",
  R"ESC(bdev_req_offset)ESC",
  R"ESC(bdev_req_len)ESC",
  R"ESC(bdev_req_tag)ESC",
  R"ESC(bdev_req_ready)ESC",
  R"ESC(bdev_data_valid)ESC",
  R"ESC(bdev_data_data_upper)ESC",
  R"ESC(bdev_data_data_lower)ESC",
  R"ESC(bdev_data_tag)ESC",
  R"ESC(bdev_data_ready)ESC",
  R"ESC(bdev_rresp_data_upper)ESC",
  R"ESC(bdev_rresp_data_lower)ESC",
  R"ESC(bdev_rresp_tag)ESC",
  R"ESC(bdev_rresp_valid)ESC",
  R"ESC(bdev_rresp_ready)ESC",
  R"ESC(bdev_wack_tag)ESC",
  R"ESC(bdev_wack_valid)ESC",
  R"ESC(bdev_wack_ready)ESC",
  R"ESC(bdev_reqs_pending)ESC",
  R"ESC(bdev_wack_stalled)ESC",
  R"ESC(bdev_rresp_stalled)ESC"
};
static uint32_t BLOCKDEVBRIDGEMODULE_0_W_addrs [26] = {
  64,
  65,
  66,
  67,
  68,
  69,
  70,
  71,
  72,
  73,
  74,
  75,
  76,
  77,
  78,
  79,
  80,
  81,
  82,
  83,
  84,
  85,
  86,
  87,
  88,
  89
};
#define BLOCKDEVBRIDGEMODULE_0_latency_bits 24
#define BLOCKDEVBRIDGEMODULE_0_num_trackers 1

// Widget: ClockBridgeModule_0
#define CLOCKBRIDGEMODULE_0(x) CLOCKBRIDGEMODULE_0_ ## x
#ifndef CLOCKBRIDGEMODULE_struct_guard
#define CLOCKBRIDGEMODULE_struct_guard
typedef struct CLOCKBRIDGEMODULE_struct {
    unsigned long hCycle_0;
    unsigned long hCycle_1;
    unsigned long hCycle_latch;
    unsigned long tCycle_0;
    unsigned long tCycle_1;
    unsigned long tCycle_latch;
} CLOCKBRIDGEMODULE_struct;
#endif // CLOCKBRIDGEMODULE_struct_guard

#define CLOCKBRIDGEMODULE_0_PRESENT
#define CLOCKBRIDGEMODULE_0_substruct_create \
CLOCKBRIDGEMODULE_struct * CLOCKBRIDGEMODULE_0_substruct = (CLOCKBRIDGEMODULE_struct *) malloc(sizeof(CLOCKBRIDGEMODULE_struct)); \
CLOCKBRIDGEMODULE_0_substruct->hCycle_0 = 136; \
CLOCKBRIDGEMODULE_0_substruct->hCycle_1 = 137; \
CLOCKBRIDGEMODULE_0_substruct->hCycle_latch = 138; \
CLOCKBRIDGEMODULE_0_substruct->tCycle_0 = 139; \
CLOCKBRIDGEMODULE_0_substruct->tCycle_1 = 140; \
CLOCKBRIDGEMODULE_0_substruct->tCycle_latch = 141; \

const static uint32_t CLOCKBRIDGEMODULE_0_R_num_registers = 4;
static const char* const CLOCKBRIDGEMODULE_0_R_names [4] = {
  R"ESC(hCycle_0)ESC",
  R"ESC(hCycle_1)ESC",
  R"ESC(tCycle_0)ESC",
  R"ESC(tCycle_1)ESC"
};
static uint32_t CLOCKBRIDGEMODULE_0_R_addrs [4] = {
  136,
  137,
  139,
  140
};
const static uint32_t CLOCKBRIDGEMODULE_0_W_num_registers = 2;
static const char* const CLOCKBRIDGEMODULE_0_W_names [2] = {
  R"ESC(hCycle_latch)ESC",
  R"ESC(tCycle_latch)ESC"
};
static uint32_t CLOCKBRIDGEMODULE_0_W_addrs [2] = {
  138,
  141
};

// Widget: LoadMemWidget_0
#define LOADMEMWIDGET_0(x) LOADMEMWIDGET_0_ ## x
#ifndef LOADMEMWIDGET_struct_guard
#define LOADMEMWIDGET_struct_guard
typedef struct LOADMEMWIDGET_struct {
    unsigned long W_ADDRESS_H;
    unsigned long W_ADDRESS_L;
    unsigned long W_LENGTH;
    unsigned long ZERO_OUT_DRAM;
    unsigned long W_DATA;
    unsigned long ZERO_FINISHED;
    unsigned long R_ADDRESS_H;
    unsigned long R_ADDRESS_L;
    unsigned long R_DATA;
} LOADMEMWIDGET_struct;
#endif // LOADMEMWIDGET_struct_guard

#define LOADMEMWIDGET_0_PRESENT
#define LOADMEMWIDGET_0_substruct_create \
LOADMEMWIDGET_struct * LOADMEMWIDGET_0_substruct = (LOADMEMWIDGET_struct *) malloc(sizeof(LOADMEMWIDGET_struct)); \
LOADMEMWIDGET_0_substruct->W_ADDRESS_H = 112; \
LOADMEMWIDGET_0_substruct->W_ADDRESS_L = 113; \
LOADMEMWIDGET_0_substruct->W_LENGTH = 114; \
LOADMEMWIDGET_0_substruct->ZERO_OUT_DRAM = 115; \
LOADMEMWIDGET_0_substruct->W_DATA = 116; \
LOADMEMWIDGET_0_substruct->ZERO_FINISHED = 117; \
LOADMEMWIDGET_0_substruct->R_ADDRESS_H = 118; \
LOADMEMWIDGET_0_substruct->R_ADDRESS_L = 119; \
LOADMEMWIDGET_0_substruct->R_DATA = 120; \

const static uint32_t LOADMEMWIDGET_0_R_num_registers = 5;
static const char* const LOADMEMWIDGET_0_R_names [5] = {
  R"ESC(W_ADDRESS_H)ESC",
  R"ESC(W_ADDRESS_L)ESC",
  R"ESC(ZERO_FINISHED)ESC",
  R"ESC(R_ADDRESS_H)ESC",
  R"ESC(R_DATA)ESC"
};
static uint32_t LOADMEMWIDGET_0_R_addrs [5] = {
  112,
  113,
  117,
  118,
  120
};
const static uint32_t LOADMEMWIDGET_0_W_num_registers = 7;
static const char* const LOADMEMWIDGET_0_W_names [7] = {
  R"ESC(W_ADDRESS_H)ESC",
  R"ESC(W_ADDRESS_L)ESC",
  R"ESC(W_LENGTH)ESC",
  R"ESC(ZERO_OUT_DRAM)ESC",
  R"ESC(W_DATA)ESC",
  R"ESC(R_ADDRESS_H)ESC",
  R"ESC(R_ADDRESS_L)ESC"
};
static uint32_t LOADMEMWIDGET_0_W_addrs [7] = {
  112,
  113,
  114,
  115,
  116,
  118,
  119
};
#define MEM_DATA_CHUNK 2ULL
// Host FPGA memory mapping for region: MainMemory_0
const static int64_t MainMemory_0_offset = -2147483648LL;
// Host FPGA memory mapping for region: MMIOEdge
const static int64_t MMIOEdge_offset = 15569256448LL;

// Simulation Constants
#define CTRL_ID_BITS 12
#define CTRL_ADDR_BITS 25
#define CTRL_DATA_BITS 32
#define CTRL_STRB_BITS 4
#define CTRL_BEAT_BYTES 4
#define CTRL_AXI4_SIZE 2
#define MEM_NUM_CHANNELS 2
#define MEM_ADDR_BITS 34
#define MEM_DATA_BITS 64
#define MEM_ID_BITS 16
#define MEM_STRB_BITS 8
#define MEM_BEAT_BYTES 8
#define MEM_SIZE_BITS 3
#define MEM_LEN_BITS 8
#define MEM_RESP_BITS 2
#define DMA_ID_BITS 6
#define DMA_ADDR_BITS 64
#define DMA_DATA_BITS 512
#define DMA_STRB_BITS 64
#define DMA_BEAT_BYTES 64
#define DMA_SIZE 6
#define MEM_HAS_CHANNEL0 1
#define MEM_HAS_CHANNEL1 1
#endif  // __FIRESIM_H
