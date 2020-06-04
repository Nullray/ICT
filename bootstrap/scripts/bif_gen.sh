#!/bin/bash

mkdir -p boot_bin

BIF_FILE=boot_bin/boot_gen.bif

touch $BIF_FILE

echo "the_ROM_image:
{
	[fsbl_config] a53_x64
	[bootloader] ../fsbl/bl2.elf
	[destination_cpu = pmu] ../pmufw/pmufw.elf"  > $BIF_FILE
if [ "$1" = "y" ]; 
then
	echo -e "	[destination_device = pl] ../../hw_plat/$2/system.bit" >> $BIF_FILE
fi
	echo -e "	[destination_cpu = a53-0, exception_level = el-3, trustzone] ../../software/arm-atf/bl31.elf\n" >> $BIF_FILE
if [ "$3" = "y" ];
then
	echo -e "	[destination_cpu = a53-0, exception_level = el-1, trustzone] ../../software/arm-tee/bl32.elf\n" >> $BIF_FILE
fi
echo -e "	[destination_cpu = a53-0, exception_level = el-2] ../../software/arm-uboot/u-boot.elf" >> $BIF_FILE
echo "}" >> $BIF_FILE
