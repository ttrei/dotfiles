#!/usr/bin/env bash

SCRIPTDIR="$( cd "$(dirname "$0")" || exit >/dev/null 2>&1 ; pwd -P )"

set -o errexit
set -o pipefail

# shellcheck disable=SC1091
source "$SCRIPTDIR/env.sh"

qemu-img create -f raw "$QEMU_GUEST_IMAGE" 100G

qemu-system-x86_64\
    -enable-kvm\
    -m 8G\
    -vga virtio\
    -display gtk,gl=on,show-cursor=on\
    -drive file="$QEMU_GUEST_IMAGE",format=raw,index=0,media=disk,if=virtio\
    -drive file="$INSTALLATION_IMAGE",index=2,media=cdrom\
    -boot order=d\
    -device virtio-net-pci,netdev=net0\
    -netdev user,id=net0,hostfwd=tcp::"$QEMU_GUEST_PORT"-:22\

