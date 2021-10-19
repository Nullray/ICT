#!/bin/bash

mkdir -p boot_bin

BIF_FILE=boot_bin/boot_gen.bif

touch $BIF_FILE

echo "the_ROM_image:
{" > $BIF_FILE

# zynqmp specific header
if [ "$1" = "zynqmp" ]
then
	echo -e "	[fsbl_config] a53_x64" >> $BIF_FILE
fi

# FSBL
	echo -e "	[bootloader] ../fsbl/bl2.elf" >> $BIF_FILE

# PMUFW for zynqmp
if [ "$1" = "zynqmp" ]
then
	echo -e "	[destination_cpu = pmu] ../pmufw/pmufw.elf"  >> $BIF_FILE
fi

# FPGA bitstream if existing
if [ "$2" = "y" ]; 
then
if [ "$1" == "zynqmp" ]
then
	echo -e "	[destination_device = pl] ../../hw_plat/$3/system.bit" >> $BIF_FILE
else
	echo -e "	../../hw_plat/$3/system.bit" >> $BIF_FILE
fi
fi

# ATF and TEE (if existing) for zynqmp
if [ "$1" == "zynqmp" ]
then
	echo -e "	[destination_cpu = a53-0, exception_level = el-3, trustzone] ../../software/arm-atf/bl31.elf\n" >> $BIF_FILE
if [ "$4" = "y" ];
then
	echo -e "	[destination_cpu = a53-0, exception_level = el-1, trustzone] ../../software/arm-tee/bl32.elf\n" >> $BIF_FILE
fi
fi

# U-Boot or baremetal
if [ "$4" == "y" ]
then
if [ "$1" == "zynqmp" ]
then
	echo -e "	[destination_cpu = a53-0, exception_level = el-2] ../servefw/executable.elf" >> $BIF_FILE
else
	echo -e "	../servefw/executable.elf" >> $BIF_FILE
fi
else
if [ "$1" == "zynqmp" ]
then
	echo -e "	[destination_cpu = a53-0, exception_level = el-2] ../../software/arm-uboot/u-boot.elf" >> $BIF_FILE
else
	echo -e "	../../software/arm-uboot/u-boot.elf" >> $BIF_FILE
fi
fi
echo "}" >> $BIF_FILE
