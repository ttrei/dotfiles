#!/usr/bin/env bash

set -o errexit
set -o nounset

DOTFILES="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"

cd "$DOTFILES" || exit 1

nix build .#nixosConfigurations.saturn-qemu.config.system.build.vm
