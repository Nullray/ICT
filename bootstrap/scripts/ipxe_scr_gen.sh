#!/bin/bash

IPXE_LOC=ipxe/src/bin-arm64-efi

mkdir -p $IPXE_LOC 

IPXE_SCRIPT=$IPXE_LOC/ipxe_script

touch $IPXE_SCRIPT

ISCSI_IQN=$1

echo "#!ipxe
dhcp
sanhook --no-describe $ISCSI_IQN || goto fail 
sanboot --no-describe --filename \\EFI\\BOOT\\bootaa64.efi || goto fail 
fail:
echo Error and Opening Shell
shell"  > $IPXE_SCRIPT

