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

### Install home-manager on non-NixOS distro

Install nix in multi-user mode:
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
echo "192.168.8.201   pluto" | sudo tee -a /etc/hosts
echo "trusted-users = reinis" | sudo tee -a /etc/nix/nix.conf
sudo systemctl restart nix-daemon.service
mkdir -p ~/.local/state/nix/profiles
nix run home-manager/master -- init --switch
rm -rf ~/.config/home-manager
bin/apply-users.sh
```

### Install home-manager on NixOS

```
nix run home-manager/master -- init --switch
rm -rf ~/.config/home-manager
nix/bin/apply-users.sh
```

### Set up password store

```shell
GNUPGHOME=<other-partition>/home/reinis/.gnupg gpg --export-secret-keys reinis > key.asc
gpg --import key.asc
shred key.asc && rm key.asc
```

### Set up shell history

```shell
pass other/atuin.sh
atuin login
atuin sync
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

## Hosts

charon: Android phone (the actual hostname is different, didn't try to change it)
eris: Raspberry Pi 1 (CA server), (static dhcp ip 192.168.8.42, mac B8:27:EB:CB:3A:E6)
jupiter: Desktop workstation (NixOS)
jupiter-work: Desktop workstation (NixOS) (static dhcp ip 192.168.8.151, mac 3C:84:6A:B5:9B:27)
mercury: Work laptop (Debian WSL) (static dhcp ip 192.168.8.150, mac DC:FB:48:72:6B:90)
neptune: Digitalocean VPS, taukulis.lv, 142.93.226.85 (previously 159.65.84.88)
pluto: Raspberry Pi 4, (static dhcp ip 192.168.8.201, mac D8:3A:DD:AF:8F:B9)
saturn: HTPC (NixOS), (static dhcp ip 192.168.8.205, mac 90:DE:80:02:B4:07)

printer-brother (static dhcp ip 192.168.8.215, mac A8:6B:AD:18:5A:5D)
airgradientA (kitchen) (static dhcp ip 192.168.8.110, mac D8:3B:DA:1F:99:44)
TODO
airgradientB (bedroom) (static dhcp ip 192.168.8.111, mac ???)

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
