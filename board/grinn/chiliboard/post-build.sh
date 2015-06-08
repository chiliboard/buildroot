#!/bin/sh
#post-build script for chiliboard

cp board/grinn/chiliboard/uEnv.txt ${BINARIES_DIR}/uEnv.txt
cp board/grinn/chiliboard/mkcard.sh ${BINARIES_DIR}/mkcard.sh

install -m 0644 -D ${BINARIES_DIR}/*.dtb ${TARGET_DIR}/boot/am335x-chiliboard.dtb

install -m 0644 -D board/grinn/chiliboard/firmware/am335x-pm-firmware.elf ${TARGET_DIR}/lib/firmware/am335x-pm-firmware.elf
install -m 0644 -D board/grinn/chiliboard/firmware/am335x-bone-scale-data.bin ${TARGET_DIR}/lib/firmware/am335x-bone-scale-data.bin

install -m 0644 -D board/grinn/chiliboard/70-power-switch.rules ${TARGET_DIR}/lib/udev/rules.d/70-power-switch.rules

install -m 0775 -D board/grinn/chiliboard/ti-gfx ${TARGET_DIR}/usr/sbin/ti-gfx