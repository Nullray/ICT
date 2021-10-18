/******************************************************************************
*
* Copyright (C) 2019 Institute of Computing Technology, Chinese Academy of Sciences  
* All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/
/*****************************************************************************/
/**
*
* @file rv_boot_env_setup.c
*
*
* @note This program uses file system within SD card 
* to read the binary boot loader image of RISC-V rocket-chip
* that would also be written to the pre-determined memory location in PS memory.
*
* The file name of boot loader image is "0:/RV_BOOT.bin"
* where O indicates the logical drive number of your SD card
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Author								Date     Changes
* ----- ----------------------------------- -------- -----------------------------------------------
* 1.00a Yisong Chang(changyisong@ict.ac.cn) 02/12/19 First release
*
*</pre>
*
******************************************************************************/

/***************************** Include Files *********************************/

#include "xparameters.h"	/* SDK generated parameters */
#include "xsdps.h"		/* SD device driver */
#include "xil_printf.h"
#include "ff.h"
#include "xil_cache.h"
#include "xplatform_info.h"
#include "xil_mmu.h"

/***************** Macros (Inline Functions) Definitions *********************/
#define RV_DRAM_ENTRY	0x10000000UL

#ifdef USE_ZYNQMP
#define SEC_SIZE	0x200000
#define RV_RESET_REG	0x83C00000UL
#else
#define SEC_SIZE	0x100000
#define RV_RESET_REG	0x43C00000UL
#endif

#define FILE_SIZE_MB	0x20UL

/************************** Function Prototypes ******************************/
int FfsSdPolledExample(void);

/************************** Variable Definitions *****************************/
static FIL fil;		/* File object */
static FATFS fatfs;
/*
 * To test logical drive 0, FileName should be "0:/<File name>" or
 * "<file_name>". For logical drive 1, FileName should be "1:/<file_name>"
 */
static char FileName[32] = "RV_BOOT.bin";
static char *SD_File;

#ifdef USE_ZYNQMP
static u64 FileSize = (FILE_SIZE_MB * 1024 * 1024);
#else
static u32 FileSize = (FILE_SIZE_MB * 1024 * 1024);
#endif

#ifdef USE_ZYNQMP
volatile struct apu_ipc {
	uint32_t req;
	uint32_t msg[8];
	uint32_t resp[8];
} *apu_ipc_base = (void*)0x0ff00000;

#include "xipipsu.h"
static XIpiPsu Ipi;
#endif

int main(void)
{
	int Status;
#ifdef USE_ZYNQMP
	volatile u64 *rv_reset_reg;
	u64 i;
#else
	volatile u32 *rv_reset_reg;
	u32 i;
#endif
	
	INTPTR rv_dram_base;

	rv_reset_reg = (void *)RV_RESET_REG;

	xil_printf("RISC-V Boot Environment Setup... \r\n");

	/* Set non-cacheable attribute for RV_DRAM_ENTRY with the file size of RV_BOOT.bin */
	rv_dram_base = (INTPTR)RV_DRAM_ENTRY;

#ifdef USE_ZYNQMP
	for(i = 0; i < (FILE_SIZE_MB / 2); i++)
#else
	for(i = 0; i < FILE_SIZE_MB; i++)
#endif
	{
		//set uncached non-shareable section attribute
		Xil_SetTlbAttributes(rv_dram_base, NORM_NONCACHE);
		rv_dram_base += SEC_SIZE;		//lower memory using block size of 2MB
	}

	/* Load RV_BOOT.bin file from SD card to RV_DRAM_ENTRY */
	Status = FfsSdPolledExample();
	if (Status != XST_SUCCESS) {
		xil_printf("SD Polled RISC-V boot file failed \r\n");
		return XST_FAILURE;
	}

	xil_printf("Successfully load RISC-V boot file into DRAM @ 0x%08x \r\n", RV_DRAM_ENTRY);

#ifdef USE_ZYNQMP
	Xil_SetTlbAttributes((UINTPTR)apu_ipc_base, NORM_NONCACHE);
	apu_ipc_base->req = 0;

	xil_printf("IPI setup\r\n", RV_DRAM_ENTRY);

	{
		XIpiPsu_Config *cfg;

		cfg = XIpiPsu_LookupConfig(XPAR_XIPIPSU_0_DEVICE_ID);
		if (!cfg) {
			xil_printf("IPI config lookup failed\r\n");
			return XST_FAILURE;
		}

		Status = XIpiPsu_CfgInitialize(&Ipi, cfg, cfg->BaseAddress);
		if (XST_SUCCESS != Status) {
			xil_printf("IPI config initialization failed\r\n");
			return XST_FAILURE;
		}
	}
#endif

#ifdef USE_BIT
	xil_printf("Passing system contrl to RISC-V core... \r\n");

	/* release RISC-V reset signal */
	*rv_reset_reg = 0x0;
#endif

	while(1) {
#ifdef USE_ZYNQMP
		while (!apu_ipc_base->req);
		XIpiPsu_WriteMessage(&Ipi, XPAR_XIPIPS_TARGET_PSU_PMU_0_CH0_MASK, (u32*)apu_ipc_base->msg, 8, XIPIPSU_BUF_TYPE_MSG);
		XIpiPsu_TriggerIpi(&Ipi, XPAR_XIPIPS_TARGET_PSU_PMU_0_CH0_MASK);
		XIpiPsu_PollForAck(&Ipi, XPAR_XIPIPS_TARGET_PSU_PMU_0_CH0_MASK, ~0);
		XIpiPsu_ReadMessage(&Ipi, XPAR_XIPIPS_TARGET_PSU_PMU_0_CH0_MASK, (u32*)apu_ipc_base->resp, 8, XIPIPSU_BUF_TYPE_RESP);
		apu_ipc_base->req = 0;
#endif
	}

	return XST_SUCCESS;

}

/*****************************************************************************/
/**
*
* File system example using SD driver to write to and read from an SD card
* in polled mode. This example creates a new file on an
* SD card (which is previously formatted with FATFS), write data to the file
* and reads the same data back to verify.
*
* @param	None
*
* @return	XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note		None
*
******************************************************************************/
int FfsSdPolledExample(void)
{
	FRESULT Res;
	UINT NumBytesRead;

	/*
	 * To test logical drive 0, Path should be "0:/"
	 * For logical drive 1, Path should be "1:/"
	 */
	TCHAR *Path = "0:/";

	/*
	 * Register volume work area, initialize device
	 */
	Res = f_mount(&fatfs, Path, 0);

	if (Res != FR_OK) {
		return XST_FAILURE;
	}

	/*
	 * Open file with required permissions.
	 * Here - Creating new file with read/write permissions. .
	 * To open file with write permissions, file system should not
	 * be in Read Only mode.
	 */
	SD_File = (char *)FileName;

	Res = f_open(&fil, SD_File, FA_READ);
	if (Res) {
		return XST_FAILURE;
	}

	/*
	 * Pointer to beginning of file .
	 */
	Res = f_lseek(&fil, 0);
	if (Res) {
		return XST_FAILURE;
	}

	/*
	 * Read data from file.
	 */
	Res = f_read(&fil, (void*)RV_DRAM_ENTRY, FileSize,
			&NumBytesRead);
	if (Res) {
		return XST_FAILURE;
	}
	xil_printf("Total %d bytes are loaded \r\n", NumBytesRead);

	/*
	 * Close file.
	 */
	Res = f_close(&fil);
	if (Res) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}
