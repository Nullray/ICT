#!/bin/bash

OBMC_SRC=openbmc
OBMC_IMG=obmc-phosphor-image

cd $OBMC_SRC
source ./setup $1 ../$2
bitbake $OBMC_IMG 
