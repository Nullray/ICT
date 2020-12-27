#!/bin/bash

IPXE_LOC=ipxe/src/bin-arm64-efi

mkdir -p $IPXE_LOC 

IPXE_SCRIPT=$IPXE_LOC/ipxe_script

touch $IPXE_SCRIPT

TFTP=$1

INITRD=ipa-aarch64.initramfs
KERNEL=vmlinuz-5.4.0

BOOTARGS="initrd=$INITRD clk_unused_ignored\
	earlycon console=ttyPS0,115200n8 ip=dhcp noefi"

echo "#!ipxe
dhcp
initrd tftp://$TFTP/$INITRD
kernel tftp://$TFTP/$KERNEL $BOOTARGS
boot"  > $IPXE_SCRIPT

