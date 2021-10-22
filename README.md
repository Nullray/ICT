## *Welcome to the NF_card_hw_sw_dev!*

This is the **working farm** of HW-SW FPGA projects designed by the Acceleration Team in the ICT of CAS. 

***

# **Target FPGA Boards**

| Board <br> (code name) | Current Version  | Description |
| ----------------------- | ---------------- | ----------- |
| NF (nf)          |     v2.0         | Custom acceleration card w/ Xilinx ZynqMP XCZU19EG in the SERVE cloud platform|
| BH (bh)          |     v2.0         | Custom motherboard w/ Xilinx ZynqMP XCZU3EG in the SERVE cloud platform       |
| [Fidus (fidus)](https://fidus.com/wp-content/uploads/2019/01/Sidewinder_Data_Sheet.pdf#:~:text=Fidus%20created%20Sidewinder%20to%20accelerate%20networking%20and%20storage,transaction%20times%20and%20thus%20enabling%20impressive%20gains%20latency.)       |     v2.0         | Commodity FPGA card w/ the same functionality of NF card |
| UltraZ (ultraz) |      N/A     | Simple FPGA board w/ Xilinx ZynqMP XCZU2EG for undergraduates' lab projects before 2020 |
| [PYNQ (pynq)](http://www.pynq.io/board.html) |   z2   | Commodity FPGA board w/ Xilinx Zynq XC7Z020 |
|  [VCU128 (vcu128) ](https://www.xilinx.com/products/boards-and-kits/vcu128.html) | N/A | Commodity FPGA board w/ Xilinx Virtex UltraScale+ XCVU37P which contains High Bandwidth Memory (HBM) |

***

# **Development Toolset**

Currently, we leverage [Xilinx Vivado 2019.1](https://www.xilinx.com/support/documentation-navigation/design-hubs/2019-1/dh0013-vivado-installation-and-licensing-hub.html) in the FPGA design flow. We also use the HSI and ARMv7/ARMv8 GNU toolchains in Vivado SDK 2019.1 for Zynq/ZynqMP firmware and software compilations.  

[Device Tree Compiler (DTC)](https://github.com/dgibson/dtc) is required as well. 

For RISC-V emulation and prototyping, the RISC-V 64-bit GNU toolchain should be installed in advance. 

## *Pre-requisite*

1. **Toolset**: Please correctly set all your toolsets according to the requirements listed in *\<working farm path\>/build_scripts/toolset.mk* 

2. **FPGA board files**: Please check if all board files in *\<working farm path\>/fpga/board/* are copied into *\<**YOUR Vivado install path**\>/Vivado/2019.1/data/boards/board_files/* .    
If not, please copy the missed board files into *\<**YOUR Vivado install path**\>/Vivado/2019.1/data/boards/board_files/*


***
  
# **FPGA hardware design**

Users build specific FPGA projects, including block design scripts, RTL sources, HLS (i.e., Vivado HLS, Chisel sources) and design flow, and use the generic hardware design flow in this repo to generate the FPGA bitstream configuration file.
 
One design project is encouraged to organize as an independent repository which is linked into this working farm as a **submodule** in *\<working farm path\>/fpga/design/*

Existing FPGA projects as examples are listed below:

| Project Name      | Maintainer  | Description |
| ----------------- | ----------- | ----------- |
| [serve](https://github.com/ict-accel-team/SERVE) | [CHEN Yuxiao](https://github.com/imhcyx) | RISC-V prototyping |
| nvme  | [CHANG Yisong](https://github.com/chang-steve) | Dual-port PCIe root complex design for NVMe SSD on the NF and Fidus card |
| monitor | [WANG Yazhou](https://github.com/linenwang) | Preliminary provision system w/ I2C, UART and etc. on the BH motherboard |
| mpsoc | [ZHAO Ran](https://github.com/zhaoran90) | Simple test of ZynqMP PS on the NF and Fidus card |
| cod_lab_dcp | [CHEN Yuxiao](https://github.com/imhcyx) | Preliminary FPGA SHELL design for partial reconfiguration of undergraduates' simple designs in UCAS COD lab prj0 - prj2 in Spring 2021 |
| nf-debug | [CHEN Yuxiao](https://github.com/imhcyx) | FPGA SHELL for hardware debugging w/ Xilinx ILA for UCAS undergraduates' pipelined functional CPU designs on the NF card in Spring 2021 |

**Detailed project organization methods would be discussed later.**

## **Project-specific hardware generation/compilation**

This step is mainly required for projects w/ Vivado HLS, Chisel, and other high-level hardware description languages. 
Before launching FPGA design flow, high-level hardware designs need to be automatically transformed/compiled 
into an intermediate representation (IR) which is mainly described in Verilog HDL.

Custom hardware compilation/generation scripts are described in a MAKE script located into *\<fpga project repo\>/scripts/hardware.mk*. 
Users would lanuch MAKE command to the specified target in this **working farm** via:   

`make FPGA_PRJ=<project name> FPGA_BD=<target board name> <hardware compilation target>` 

in which **\<project name\>** indicates the FPGA project name that is the same w/ the directory name in *\<working farm path\>/fpga/design/*,  
**\<target board name\>** specifies the target board that is currently supported,  
and **\<hardware compilation target\>** implies the user-defined hardware design MAKE target in *\<fpga project repo\>/scripts/hardware.mk*. 

Please note that this step is also appropriate for users to launch logical simulation, verification and intermediate netlist synthesis that is 
defined as MAKE targets in your own FPGA project.

## **FPGA design flow**

Please launch  

`make FPGA_PRJ=<project name> FPGA_BD=<target board name> fpga`   

to automatically setup a Vivado project, run top-level synthesis, place and routing, as well as generate an FPGA configuration bitstream file. 

The required hardware design sources, timing/physical constraints and specific design flow settings are located in *\<working farm path\>/fpga/design/\<project name\>*.  

The auto-generated HDF (leveraged in Zynq/ZynqMP firmware compilation) and bitstream file would be located in hw_plat/\<FPGA_PRJ\>_\<FPGA_BD\>.  

For detailed FPGA design steps, please refer to *\<working farm path\>/build_scripts/fpga.mk*

***
  
# **Software design**

Compilation of software stack that accommandates to the FPGA design project is also managed in this **working farm**.  

Basic software stack are listed below
| Software Name      | Maintainer  | Description |
| ------------------ | ----------- | ----------- |
| **Bootstrap** |
| First Level Boot Loader (FSBL) | N/A | Auto-generation w/ Xilinx Vivado SDK Toolset |
| PMU Firmware | N/A | Running on Microblaze core in ZynqMP. Auto-generation w/ Xilinx Vivado SDK Toolset |
| [Auto-generation of Device Tree Source](https://github.com/ict-accel-team/device-tree-xlnx) | [CHANG Yisong](https://github.com/chang-steve) | Auto-generation w/ Xilinx Vivado SDK Toolset for Zynq and ZynqMP |
| zsbl | [Qi Le](https://github.com/wuyouniyanhu) | RISC-V Rocket-chip BootROM on SERVE platforms |
| servefw | [CHEN Yuxiao](https://github.com/imhcyx) | Zynq/ZynqMP simple firmware for RISC-V prototyping on SERVE |
| **Software** |
| [ARM Trusted Firmware](https://github.com/ict-accel-team/arm-trusted-firmware) | [CHANG Yisong](https://github.com/chang-steve) | ARMv8 EL3 firmware on ZynqMP only |
| [OpenSBI](https://github.com/ict-accel-team/opensbi) | [CHEN Yuxiao](https://github.com/imhcyx) | RISC-V M-mode firmware|
| [U-Boot](https://github.com/ict-accel-team/u-boot-xlnx)  | [CHANG Yisong](https://github.com/chang-steve) | For ARM on Zynq/ZynqMP and other alternative ISAs (e.g., RISC-V) <br> **Current version**: v2020.01 |
| [Linux](https://github.com/ict-accel-team/linux-xlnx) | [CHANG Yisong](https://github.com/chang-steve) | For ARM on Zynq/ZynqMP and other alternative ISAs (e.g., RISC-V) <br> **Current version**: v5.4 |
| [OpenBMC](https://github.com/ict-accel-team/openbmc) | [CHANG Yisong](https://github.com/chang-steve) | initrd for the BH motherboard | 

Compilation flags for all these software frameworks are specified in *\<working farm path\>/build_scripts/bootstrap.mk* and *\<working farm path\>/build_scripts/software.mk*, respectively.   
Detailed MAKE scripts of each software framework is located in *\<working farm path\>/bootstrap/scripts/* or *\<working farm path\>/software/scripts/*.

**Compilation details of each software framework would be summaried later.**

## Binary BOOT image (BOOT.bin)

In our current design, a BOOT.bin file is deployed on Zynq/ZynqMP boards for early-stage (before loading Linux kernel) system boot. Moreover, an RV_BOOT.bin is also required for RISC-V prototyping. As a result, we provide a special MAKE target in the **working farm** to auto-compile all dependent components that are composed of the output BOOT.bin file for users:  

`make FPGA_PRJ=<project name> FPGA_BD=<target board name> WITH_BIT=y bootbin` for Zynq/ZynqMP (**MUST** be launched after FPGA design flow), and  

`make FPGA_PRJ=<project name> FPGA_BD=<target board name> ARCH=riscv bootbin` for RISC-V, respectively. 

Detailed compilation settings are described in *\<working farm path\>/build_scripts/bootbin.mk* for MAKE target definations,  
and *\<working farm path\>/bootstrap/boot_bin.mk* for Zynq/ZynqMP as well as *\<working farm path\>/software/opensbi.mk* for RISC-V, respectively. 

All generated image files are located in *ready_for_download/\<FPGA_PRJ\>_\<FPGA_BD\>/\<ARCH\>*

## Linux kernel compilation for physical machines

An kernel image in Image format would be compiled via:  

`make FPGA_PRJ=<project name> FPGA_BD=<target board name> phy_os.os` for Zynq/ZynqMP, and  

`make FPGA_PRJ=<project name> FPGA_BD=<target board name> ARCH=riscv phy_os.os` for RISC-V, respectively. 

All generated image files are located in *ready_for_download/\<FPGA_PRJ\>_\<FPGA_BD\>/\<ARCH\>/\<phy_os\>/*
