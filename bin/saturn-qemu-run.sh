#!/usr/bin/env bash

set -o errexit
set -o nounset

DOTFILES="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"

cd "$DOTFILES" || exit 1

export QEMU_OPTS="-m 4096 -smp 4"
export NIX_DISK_IMAGE=/media/storage-new/qemu/saturn-qemu.qcow2

./result/bin/run-saturn-qemu-vm
