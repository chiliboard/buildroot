#! /bin/bash -u
export LC_ALL=C

if [ $# -ne 1 ]; then
	echo "Usage: $0 <drive>"
	exit 1;
fi

IMAGE=sdcard.img
DEVICE=$1
BS=128k

ERROR() {
    echo "[EE] $1"
    exit 1
}


rerun_as_root() {
    if [ "$(whoami)" != "root" ]; then
        exec sudo -- "$0" "$@"
        exit $?
    fi
}

rerun_as_root $@

if [ "$EUID" -ne 0 ]; then
    ERROR "Please run this script as root: 'sudo $0'"
fi  

[ ! -b ${DEVICE} ] && ERROR "Device ${DEVICE} is not block device!"
[ ! -w ${DEVICE} ] && ERROR "Cannot write to ${DEVICE}!"

grep -q ${DEVICE} /proc/mounts && ERROR "Loop '${DEVICE}' is already mounted. Please unmount it."

command -v pv &>/dev/zero
if [ $? -eq 0 ]; then
    CAT=pv
else
    echo "To see progress bar, please install 'pv' utility"
    CAT=cat
fi


$CAT ${IMAGE} | dd of=${DEVICE} bs=${BS} oflag=dsync conv=fsync

