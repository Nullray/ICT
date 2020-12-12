#!/bin/bash

OBMC_SRC=openbmc
OBMC_LOC=arm-openbmc
OBMC_BD=zcu102-zynqmp
OBMC_IMG=obmc-phosphor-image

cd $OBMC_SRC
source ./setup $OBMC_BD ../$OBMC_LOC
bitbake $OBMC_IMG 
