#!/usr/bin/env bash

DOTFILES="$( cd "$(dirname "$0")/../.." || exit >/dev/null 2>&1 ; pwd -P )"

parted /dev/vda -- mklabel msdos
parted /dev/vda -- mkpart primary 1MiB -2GiB
parted /dev/vda -- set 1 boot on
parted /dev/vda -- mkpart primary linux-swap -2GiB 100%

mkfs.ext4 -L nixos /dev/vda1
mkswap -L swap /dev/vda2

sleep 1 # let nixos appear in /dev/disk/by-label/

mount /dev/disk/by-label/nixos /mnt
swapon /dev/vda2

mkdir -p /mnt/etc/nixos/hosts

# Copy our configuration to /mnt/etc/nixos
pushd "$DOTFILES/nix" || exit

# TODO: This is probably broken after the migration to flake-based config.

cp nixos-config/configuration-22.11.nix /mnt/etc/nixos/configuration.nix
cp nixos-config/hosts/qemu-base.nix /mnt/etc/nixos/hosts/custom.nix
cp -r \
    nixos-config/hardware-configurations \
    nixos-config/packages \
    nixos-config/users \
    nixos-config/bin \
    overlays \
    /mnt/etc/nixos

popd || exit

nixos-install

rm -rf /mnt/etc/nixos
