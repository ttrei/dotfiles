#!/usr/bin/env sh

set -e

parted /dev/sda -- mklabel msdos
parted /dev/sda -- mkpart primary 1MiB 100%
mkfs.ext4 -L nixos /dev/sda1
mount /dev/sda1 /mnt

mkdir -p /mnt/etc
nix-env -iA nixos.git
git clone ssh://reinis@178.62.54.226:/home/reinis/gitrepos/nixos.git /mnt/etc/nixos
cd /mnt/etc/nixos
git checkout desktop-qemu
nixos-generate-config --root /mnt --show-hardware-config > /mnt/etc/nixos/hardware-configuration.nix
nixos-install --option binary-caches http://192.168.122.35:80
reboot
