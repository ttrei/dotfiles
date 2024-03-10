# dotfiles

Configuration for the software I use.

The configuration files are organized by area: terminal, net, nvim, etc.
The file tree doesn't directly reflect how it will look when deployed to home directory.

It is my intention to gradually migrate all configuration to
[home-manager](https://github.com/nix-community/home-manager).

## Deploy

1. Choose a deployment target config from `configs/` by running `bin/select-config.sh`.
   The config file will be copied to `$HOME/.dotfiles-env`.
2. Execute `bin/deploy.sh`.

### Install home-manager

On non-NixOS, first install nix in multi-user mode:
``` shell
sh <(curl -L https://nixos.org/nix/install) --daemon
# sh <(curl -L https://nixos.org/nix/install) < /dev/null --daemon # unattended

# Note 2023-07-25
# On Ubuntu 22.04 LTS had to install older nix to avoid some breakage:
# https://github.com/nix-community/home-manager/issues/3734#issuecomment-1642757696
curl -L https://releases.nixos.org/nix/nix-2.13.0/install | sh -s -- --daemon
```

Install home-manager:
``` shell
# TODO: Check if these instructions work on NixOS.
mkdir -p ~/.local/state/nix/profiles
nix run home-manager/master -- init --switch
rm -rf ~/.config/home-manager
apply-users.sh
```

## Deployment target configuration variables

DISTRO

* debian
* ubuntu
* nixos

CONTEXT

* home
* work

MACHINE (hostname, see below)

EXECUTION_ENV

* baremetal
* qemu
* wsl
* digitalocean

## Hostnames

pluto: Raspberry Pi 4
eris: Raspberry Pi 1 (CA server)
mercury: Work laptop (Debian WSL)
saturn: HTPC (NixOS)
jupiter: Desktop workstation (NixOS)
jupiter-work: Desktop workstation (Ubuntu)

Still need to change hostname:
charon: Android phone
neptune: Digitalocean VPS

### Available hostnames

venus
earth
mars
uranus

ganymede
titan
callisto
io
moon
europa
triton
titania
rhea
oberon
iapetus
umbriel
ariel
dione
tethys
dysnomia
