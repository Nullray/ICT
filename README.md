Welcome to the NF_card_hw_sw_dev! 

This is the working farm of HW-SW FPGA projects designed by the Acceleration Team in the ICT of CAS. 

***

# **Target FPGA Boards**

| Boards (code name)      | Current Version  | Description |
| ----------------------- | ---------------- | ----------- |
| NF (nf)          |     v2.0         | Custom acceleration card w/ Xilinx ZynqMP XCZU19EG in the SERVE cloud platform|
| BH (bh)          |     v2.0         | Custom motherboard w/ Xilinx ZynqMP XCZU3EG in the SERVE cloud platform       |
| [Fidus (fidus)](https://fidus.com/wp-content/uploads/2019/01/Sidewinder_Data_Sheet.pdf#:~:text=Fidus%20created%20Sidewinder%20to%20accelerate%20networking%20and%20storage,transaction%20times%20and%20thus%20enabling%20impressive%20gains%20latency.)       |     v2.0         | Commodity FPGA card w/ the same functionality of NF card |
| UltraZ (ultraz) |      N/A     | Simple FPGA board w/ Xilinx ZynqMP XCZU2EG for undergraduates' lab projects before 2020 |
| [PYNQ (pynq)](http://www.pynq.io/board.html) |   z2   | Commodity FPGA board w/ Xilinx Zynq XC7Z020 |
| [VCU128 (vcu128)](https://www.xilinx.com/products/boards-and-kits/vcu128.html) | N/A | Commodity FPGA board w/ Xilinx Virtex UltraScale+ XCVU37P which contains High Bandwidth Memory (HBM) |

# **FPGA Development Toolset**

Currently, we leverage [Xilinx Vivado 2019.1 w/ SDK](https://www.xilinx.com/support/documentation-navigation/design-hubs/2019-1/dh0013-vivado-installation-and-licensing-hub.html). 

Before launching design flow, please check if all board files in \<repo path\>/fpga/board/ are located in \<**YOUR Vivado install path**\>/Vivado/2019.1/data/boards/board_files/ .

If not, please copy the missed board files into \<**YOUR Vivado install path**\>/Vivado/2019.1/data/boards/board_files/

# **Fundamental Design Flow**
  
## **Hardware logic design**

Users build specific FPGA projects, including block design scripts, RTL sources, HLS (i.e., Vivado HLS, Chisel sources) and design flow.
 
One design project would be built as an independent repository and linked into this working farm as a **submodule** in \<repo path\>/fpga/design/

Existing FPGA projects are listed below:

| Project Name      | Maintainer  | Description |
| ----------------- | ----------- | ----------- |
| [serve](https://github.com/ict-accel-team/SERVE) | [CHEN Yuxiao](https://github.com/imhcyx) | RISC-V prototyping |
| nvme  | [CHANG Yisong](https://github.com/chang-steve) | Dual-port PCIe root complex design for NVMe SSD on the NF and Fidus card |
| monitor | [WANG Yazhou](https://github.com/linenwang) | Preliminary provision system w/ I2C, UART and etc. on the BH motherboard |
| mpsoc | [ZHAO Ran](https://github.com/zhaoran90) | Simple test of ZynqMP PS on the NF and Fidus card |
| cod_lab_dcp | [CHEN Yuxiao](https://github.com/imhcyx) | Preliminary FPGA SHELL design for partial reconfiguration of undergraduates' simple design in COD lab prj0 - prj2 in Spring 2021 |
| nf-debug | [CHEN Yuxiao](https://github.com/imhcyx) | FPGA SHELL for hardware debugging w/ Xilinx ILA for undergraduates' pipelined functional CPU design on the NF card in Spring 2021 |

## **Automatically launch FPGA design flow**

`make FPGA_PRJ=xxx FPGA_BD=xxx fpga`

FPGA_PRJ indicates user-specified FPGA project in this design. All sources and scripts are located in the sub directory in fpga/design

FPGA_BD indicates target FPGA board to deploy. Please check the code name of currently leveraged FPGA boards listed in xxx. 

Auto-generated HDF and bitstream file would be located in hw_plat/\<FPGA_PRJ\>_\<FPGA_BD\>

* **Automatically launch software compilation and generation on Zynq and ZyqnMP**

`make FPGA_PRJ=xxx FPGA_BD=xxx sw`

In software compilation flow, users must specify the target FPGA board and FPGA project in which such software or image would be deployed and leveraged. 

If you want to package bitstream file in BOOT.bin image, please launch:   
`make FPGA_PRJ=xxx FPGA_BD=xxx WITH_BIT=y sw`

All generated image files are located in ready_for_download/\<FPGA_PRJ\>_\<FPGA_BD\>

Basic software stack for Zynq and ZynqMP are listed below
| Software Name      | Maintainer  | Description |
| ------------------ | ----------- | ----------- |
| First Level Boot Loader (FSBL) | N/A | Auto-generation w/ Xilinx Vivado SDK Toolset |
| [ARM Trusted Firmware](https://github.com/ict-accel-team/arm-trusted-firmware) | [CHANG Yisong](https://github.com/chang-steve) | For ZynqMP only |
| [U-Boot](https://github.com/ict-accel-team/u-boot-xlnx)  | [CHANG Yisong](https://github.com/chang-steve) | |
| [Linux](https://github.com/ict-accel-team/linux-xlnx) | [CHANG Yisong](https://github.com/chang-steve) | |
| [Auto-generation of Device Tree Source](https://github.com/ict-accel-team/device-tree-xlnx) | [CHANG Yisong](https://github.com/chang-steve) | Auto-generation w/ Xilinx Vivado SDK Toolset |
| PMU Firmware | N/A | Running on Microblaze core in ZynqMP. Auto-generation w/ Xilinx Vivado SDK Toolset |
| [OpenBMC](https://github.com/ict-accel-team/openbmc) | [CHANG Yisong](https://github.com/chang-steve) | initrd for the BH motherboard | 

# **Project-specific hardware/software compilation**

Some project-specific hardware and software (e.g., [serve project](https://github.com/ict-accel-team/SERVE)) should be generated or compiled before launching FPGA design flow. 

In this section, we would like to take [serve project](https://github.com/ict-accel-team/SERVE) as an example to show how to process project-specific compilations and how to 
organize hardware and software source files in a specified project. 

* **Step #1**

Edit *default.mk* to setup basic compilation parameters of SERVE project.   

If you are not willing to modify *default.mk*, please launch specific parameters in the following make command line

* **Step #2**

Launch `make FPGA_PRJ=serve FPGA_BD=xxx prj_hw` to generate top-module of RISC-V SoC from SERVE repositary.   

\<FPGA_BD\> should be identified by the corresponding platform listed in README.md of SERVE repo.   

If you want to remove previous generation, please launch `make FPGA_PRJ=serve FPGA_BD=xxx prj_hw_clean`

* **Step #3**

Launch `make FPGA_PRJ=serve FPGA_BD=xxx PRJ_TARGET=xxx PRJ_SW=xxx prj_sw`   
to compile system software of target RISC-V prototyping.     

\<FPGA_BD\> and \<PRJ_TARGET\> should be matched as listed in SERVE repositary;    
<PRJ_SW> should be selected from `rv_boot_bin, uboot, linux and app`, all of which are software compilation targets in SERVE repositary. 

All executable files would be located in fpga/design/serve/ready_for_download
If you want to remove compiled objects and executable files of a certain software target, please launch    
`make FPGA_PRJ=serve FPGA_BD=xxx PRJ_SW=xxx prj_sw_clean`    
If you want to remove all configurations and generated files of a certain software target, please launch    
`make FPGA_PRJ=serve FPGA_BD=xxx PRJ_SW=xxx prj_sw_distclean`
