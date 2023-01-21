#!/usr/bin/env sh

[ -z "$QEMU_GUEST_IMAGE" ] && QEMU_GUEST_IMAGE=/media/storage-new/qemu/nixos.img
[ -z "$QEMU_GUEST_PORT" ] && QEMU_GUEST_PORT=6666
[ -z "$INSTALLATION_IMAGE" ] && INSTALLATION_IMAGE=/media/storage-new/install/nixos-minimal-22.11.1705.b83e7f5a04a-x86_64-linux.iso

export QEMU_GUEST_IMAGE
export QEMU_GUEST_PORT
export INSTALLATION_IMAGE
