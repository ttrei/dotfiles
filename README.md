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
3. Execute `nix/bin/apply-users.sh`.

## Deployment target configuration variables

DISTRO

* debian
* ubuntu
* nixos

CONTEXT

* home
* work

MACHINE

* home-desktop
* work-laptop
* htpc
* taukulis.lv

EXECUTION_ENV

* baremetal
* qemu
* wsl
* digitalocean
