#!/bin/sh
#post-build script for chiliboard

cp board/grinn/chiliboard/uEnv.txt ${BINARIES_DIR}/uEnv.txt
cp board/grinn/chiliboard/mkcard.sh ${BINARIES_DIR}/mkcard.sh
CURRENT_DTB=`grep BR2_LINUX_KERNEL_INTREE_DTS_NAME ${BR2_CONFIG} | sed -n 's/.*="\(.*\)".*/\1/p'`

cat /home/niziak/chili/BUILDS/br-github-2015.02-minimal/.config | grep BR2_LINUX_KERNEL_INTREE_DTS_NAME | eval && echo $BR2_LINUX_KERNEL_INTREE_DTS_NAME
if [ -n $CURRENT_DTB ]; then
    install -m 0644 -D ${BINARIES_DIR}/${CURRENT_DTB}.dtb ${TARGET_DIR}/boot/am335x-chiliboard.dtb
else
    install -m 0644 -D ${BINARIES_DIR}/*.dtb ${TARGET_DIR}/boot/am335x-chiliboard.dtb
fi

install -m 0644 -D board/grinn/chiliboard/firmware/am335x-pm-firmware.elf ${TARGET_DIR}/lib/firmware/am335x-pm-firmware.elf
install -m 0644 -D board/grinn/chiliboard/firmware/am335x-bone-scale-data.bin ${TARGET_DIR}/lib/firmware/am335x-bone-scale-data.bin

install -m 0644 -D board/grinn/chiliboard/70-power-switch.rules ${TARGET_DIR}/lib/udev/rules.d/70-power-switch.rules

install -m 0775 -D board/grinn/chiliboard/ti-gfx ${TARGET_DIR}/usr/sbin/ti-gfx
