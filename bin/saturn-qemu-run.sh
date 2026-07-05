#!/usr/bin/env bash

set -o errexit
set -o nounset

DOTFILES="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"

cd "$DOTFILES" || exit 1

# More RAM/CPUs
# QEMU_OPTS="-m 4096 -smp 4" ./result/bin/run-saturn-qemu-vm

NIX_DISK_IMAGE=/tmp/saturn-qemu.qcow2 ./result/bin/run-saturn-qemu-vm
