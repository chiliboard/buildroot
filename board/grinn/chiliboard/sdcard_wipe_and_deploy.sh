#!/bin/bash -ue
SDCARD="sdc"

FAT_SIZE="33"
EXT_SIZE="500"


SDCARD_DEV="/dev/${SDCARD}"



rerun_as_root () {
    if [ "$(whoami)" != "root" ]; then
        exec sudo -- "$0" "$@"
        exit 0
    fi
}

rerun_as_root

function RESCAN() {
    partprobe ${SDCARD_DEV}
    echo 1 > /sys/block/${SDCARD}/device/rescan
    wait_for_dev ${SDCARD_DEV}
}

function ERROR() {
    echo "[EE] $1"
    exit 1
}

function LOG() {
    echo "[II] $1"
}

function DEBUG() {
    echo "[DD] $1"
}

function wait_for_dev() {
    DEV=$1
    if [ ! -b ${DEV} ]; then
	LOG "Waiting for ${DEV}: "
    fi
    while [ ! -b ${DEV} ]; do
	echo -n "."
	sleep .1
    done
    echo
#    DEBUG "Device ${DEV} exists"
}


if [ "$EUID" -ne 0 ]; then
    ERROR "Please run this script as root: 'sudo $0'"
fi

wait_for_dev ${SDCARD_DEV}
LOG "Current SD card ${SDCARD_DEV} content"
set +e
lsblk ${SDCARD_DEV} -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL
EXITCODE=$?
set -e
if [ $EXITCODE -ne 0 ]; then
    ERROR "SD card ${SDCARD_DEV} not inserted!"
fi
#fdisk -l ${SDCARD_DEV}
LOG ""
read -p "This script will format your SD card ${SDCARD_DEV}. Write YES if you agree: " YES
if [ "x$YES" != "xYES" ]; then
    exit
fi

set +e
umount ${SDCARD_DEV}1 &>/dev/zero
umount ${SDCARD_DEV}2 &>/dev/zero
set -e

set +e
cat /proc/mounts | grep ${SDCARD_DEV} -q
EXITCODE=$?
set -e
if [ $EXITCODE -eq 0 ]; then
    ERROR "SD Card ${SDCARD_DEV} is already mounted. Please unmount it."
fi

wait_for_dev ${SDCARD_DEV}
LOG "Creating partition table on ${SDCARD_DEV}"
#dd if=/dev/zero of=${SDCARD_DEV} bs=1M count=1

sfdisk --no-reread --in-order --DOS --Linux --unit M ${SDCARD_DEV} << EOF
1,${FAT_SIZE},0xB,*
,${EXT_SIZE}
;
;
EOF

LOG "Re-reading partition table on ${SDCARD_DEV}"
RESCAN

LOG "Creating FAT on ${SDCARD_DEV}1"
wait_for_dev ${SDCARD_DEV}1
mkfs.fat ${SDCARD_DEV}1 -n BOOT

LOG "Creating EXT4 on ${SDCARD_DEV}2"
wait_for_dev ${SDCARD_DEV}2
dd if=/dev/zero of=${SDCARD_DEV}2 bs=1M count=1
mkfs.ext4 -m 0 -L "ROOT" ${SDCARD_DEV}2

BOOT_MNT_DIR="/tmp/$0.$$/${SDCARD_DEV}1"
ROOT_MNT_DIR="/tmp/$0.$$/${SDCARD_DEV}2"

LOG  "Mounting..."
mkdir -p ${BOOT_MNT_DIR}
mkdir -p ${ROOT_MNT_DIR}

mount ${SDCARD_DEV}1 ${BOOT_MNT_DIR}
mount ${SDCARD_DEV}2 ${ROOT_MNT_DIR} -O noatime,nodiratime,data=writeback

if [ ! -d ${BOOT_MNT_DIR} ]; then
    ERROR "${BOOT_MNT_DIR} not created!"
fi

if [ ! -d ${ROOT_MNT_DIR} ]; then
    ERROR "${ROOT_MNT_DIR} not created!"
fi


cp -L MLO ${BOOT_MNT_DIR}/MLO
cp -L u-boot.img ${BOOT_MNT_DIR}/u-boot.img
test -e uEnv.txt && cp uEnv.txt ${BOOT_MNT_DIR}

LOG "Copying"
cat rootfs.tar.gz | tar xz -C ${ROOT_MNT_DIR} -f -

LOG "Syncing"
sync

LOG "Unmounting"
umount ${SDCARD_DEV}1
umount ${SDCARD_DEV}2

LOG "Removing temporary dirs"
rm -rf ${BOOT_MNT_DIR}
rm -rf ${ROOT_MNT_DIR}

