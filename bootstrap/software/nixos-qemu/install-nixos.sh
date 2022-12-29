#!/usr/bin/env sh

parted /dev/vda -- mklabel msdos
parted /dev/vda -- mkpart primary 1MiB -8GiB
parted /dev/vda -- mkpart primary linux-swap -8GiB 100%

mkfs.ext4 -L nixos /dev/vda1
mkswap -L swap /dev/vda2

sleep 1 # let nixos appear in /dev/disk/by-label/

mount /dev/disk/by-label/nixos /mnt
swapon /dev/vda2

mkdir -p /mnt/etc/nixos

# Exclude GUI stuff to speed up the installation
grep -v gui.nix nixos-config/system/configuration.nix > /mnt/etc/nixos/configuration.nix

cp -r nixos-config/system/packages /mnt/etc/nixos
cp -r nixos-config/system/qemu/* /mnt/etc/nixos
cp -r overlays /mnt/etc/nixos

nixos-install

rm -rf /mnt/etc/nixos
