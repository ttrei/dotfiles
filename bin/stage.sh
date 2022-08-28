#!/usr/bin/env bash

set -o errexit
set -o nounset

DOTFILES="$( cd "$(dirname "$0")/.." || exit >/dev/null 2>&1 ; pwd -P )"
STAGINGDIR=${STAGINGDIR:-"$DOTFILES/.staging"}
ENVFILE="$HOME/.dotfiles-env"

ARG=${1:-}

print_env() {
    echo "DISTRO=$DISTRO"
    echo "CONTEXT=$CONTEXT"
    echo "MACHINE=$MACHINE"
    echo "EXECUTION_ENV=$EXECUTION_ENV"
    echo "USER=$USER"
}

if ! [ -f "$ENVFILE" ]; then
    echo "ABORT! dotfiles env file $ENVFILE not found."
    exit 1
fi
# shellcheck source=/dev/null
. "$ENVFILE"

if [ -z "$DISTRO" ] || [ -z "$CONTEXT" ] || [ -z "$MACHINE" ] || [ -z "$EXECUTION_ENV" ] || [ -z "$USER" ]; then
    echo "ABORT! Environment incomplete."
    echo ""
    print_env
    exit 1
fi

rm -rf "$STAGINGDIR"
if [ "$ARG" == "-v" ]; then
    echo "Staging to $STAGINGDIR"
fi

################################################################################
# OLD STYLE (to be gradually migrated to new style)
################################################################################

if [ "$DISTRO" = "debian" ] && [ "$CONTEXT" = "home" ] && [ "$MACHINE" = "home-desktop" ]; then
    OLD_DEPLOYMENT_NAME="home-desktop-debian"
elif [ "$DISTRO" = "debian" ] && [ "$CONTEXT" = "work" ] && [ "$MACHINE" = "home-desktop" ]; then
    OLD_DEPLOYMENT_NAME="tieto2-desktop-debian"
elif [ "$DISTRO" = "debian" ] && [ "$CONTEXT" = "work" ] && [ "$MACHINE" = "work-laptop" ]; then
    OLD_DEPLOYMENT_NAME="tieto2-laptop-debian"
elif [ "$DISTRO" = "ubuntu" ] && [ "$CONTEXT" = "home" ] && [ "$MACHINE" = "htpc" ]; then
    OLD_DEPLOYMENT_NAME="kodi"
elif [ "$DISTRO" = "nixos" ] && [ "$CONTEXT" = "home" ] && [ "$MACHINE" = "htpc" ]; then
    OLD_DEPLOYMENT_NAME="home-desktop-nixos"
elif [ "$DISTRO" = "nixos" ] && [ "$CONTEXT" = "home" ] && [ "$MACHINE" = "home-desktop" ]; then
    OLD_DEPLOYMENT_NAME="home-desktop-nixos"
elif [ "$DISTRO" = "debian" ] && [ "$CONTEXT" = "home" ] && [ "$MACHINE" = "taukulis.lv" ]; then
    OLD_DEPLOYMENT_NAME="debian"
else
    echo "ABORT! Couldn't select the old-style deployment directory."
    echo ""
    print_env
    exit 1
fi
OLD_DEPLOYMENT_DIR="$DOTFILES/.deploy-$OLD_DEPLOYMENT_NAME"
if [ "$ARG" == "-v" ]; then
    echo "Selected old-style deployment directory: $OLD_DEPLOYMENT_DIR"
fi
if ! [ -d "$OLD_DEPLOYMENT_DIR" ]; then
    echo "ABORT! Old-style deployment directory $OLD_DEPLOYMENT_DIR not found."
    exit 1
fi

cp --recursive \
    --no-dereference \
    "$OLD_DEPLOYMENT_DIR/." "$STAGINGDIR"

################################################################################
# NEW STYLE
################################################################################

mkdir -p "$STAGINGDIR/.config"
mkdir -p "$STAGINGDIR/bin"

# TERMINAL
ln -s "$DOTFILES/terminal/starship.toml" "$STAGINGDIR/.config"
ln -s "$DOTFILES/terminal/starship2.toml" "$STAGINGDIR/.config"
mkdir -p "$STAGINGDIR/.config/htop"
ln -s "$DOTFILES/terminal/htoprc" "$STAGINGDIR/.config/htop"
ln -s "$DOTFILES/terminal/bin/describe-environment.sh" "$STAGINGDIR/bin"
ln -s "$DOTFILES/terminal/envrc" "$STAGINGDIR/.envrc"

# GIT
ln -s "$DOTFILES/git/gitignore" "$STAGINGDIR/.gitignore"

# I3/SWAY
mkdir -p "$STAGINGDIR/.config/i3"
mkdir -p "$STAGINGDIR/.config/i3blocks"
mkdir -p "$STAGINGDIR/.config/sway"
mkdir -p "$STAGINGDIR/bin/i3"
cp "$DOTFILES/i3/config/config" "$STAGINGDIR/.config/i3/config"
ln -s "$DOTFILES/i3/sway/config" "$STAGINGDIR/.config/sway/config"
ln -s "$DOTFILES/i3/i3blocks/config" "$STAGINGDIR/.config/i3blocks/config"
ln -s "$DOTFILES/i3/i3blocks/blocklets" "$STAGINGDIR/.config/i3blocks/blocklets"
ln -s "$DOTFILES/i3/commands.json" "$STAGINGDIR/.config/i3/commands.json"
ln -s "$DOTFILES/i3/bin/myrmidon/confirm.sh" "$STAGINGDIR/bin/confirm.sh"
ln -s "$DOTFILES/i3/bin/myrmidon/myrmidon.sh" "$STAGINGDIR/bin/myrmidon.sh"
ln -s "$DOTFILES/i3/workspace-scripts" "$STAGINGDIR/bin/i3/workspace-scripts"
ln -s "$DOTFILES/i3/bin/i3-rename-current-workspace" "$STAGINGDIR/bin/i3/i3-rename-current-workspace"
ln -s "$DOTFILES/i3/bin/i3-start" "$STAGINGDIR/bin/i3/i3-start"
ln -s "$DOTFILES/i3/bin/i3-workspaces" "$STAGINGDIR/bin/i3/i3-workspaces"
if [ "$MACHINE" = "home-desktop" ]; then
    if [ "$CONTEXT" = "home" ]; then
        ln -s "$DOTFILES/i3/workspaces-home.txt" "$STAGINGDIR/.config/i3/workspaces.txt"
        ln -s "$DOTFILES/i3/sway/config-home" "$STAGINGDIR/.config/sway/config-home"
        cat "$DOTFILES/i3/config/config-home" >> "$STAGINGDIR/.config/i3/config"
    elif [ "$CONTEXT" = "work" ]; then
        ln -s "$DOTFILES/i3/workspaces-work.txt" "$STAGINGDIR/.config/i3/workspaces.txt"
        ln -sf "$DOTFILES/i3/i3blocks/config-tieto2" "$STAGINGDIR/.config/i3blocks/config"
    fi
elif [ "$MACHINE" = "work-laptop" ]; then
    ln -s "$DOTFILES/i3/workspaces-work.txt" "$STAGINGDIR/.config/i3/workspaces.txt"
    ln -sf "$DOTFILES/i3/i3blocks/config-tieto2" "$STAGINGDIR/.config/i3blocks/config"
elif [ "$MACHINE" = "htpc" ]; then
    ln -s "$DOTFILES/i3/sway/config-kodi" "$STAGINGDIR/.config/sway/config-kodi"
    cat "$DOTFILES/i3/config/config-kodi" >> "$STAGINGDIR/.config/i3/config"
    ln -sf "$DOTFILES/i3/i3blocks/config-kodi" "$STAGINGDIR/.config/i3blocks/config"
    ln -sf "$DOTFILES/i3/commands-kodi.json" "$STAGINGDIR/.config/i3/commands.json"
fi
if [ "$EXECUTION_ENV" = "qemu" ]; then
    ln -sf "$DOTFILES/i3/i3blocks/config-qemu" "$STAGINGDIR/.config/i3blocks/config"
fi

# VSCODE
mkdir -p "$STAGINGDIR/.config/Code/User"
ln -s "$DOTFILES/vscode/settings.json" "$STAGINGDIR/.config/Code/User/settings.json"
ln -s "$DOTFILES/vscode/keybindings.json" "$STAGINGDIR/.config/Code/User/keybindings.json"
ln -s "$DOTFILES/vscode/workspaces" "$STAGINGDIR/.config/vscode-workspaces"

# PYTHON
mkdir -p "$STAGINGDIR/.config/pip"
ln -s "$DOTFILES/python/pip.conf" "$STAGINGDIR/.config/pip/pip.conf"

# NIX
mkdir -p "$STAGINGDIR/.config/nix"
ln -s "$DOTFILES/nix/nix.conf" "$STAGINGDIR/.config/nix/nix.conf"
mkdir -p "$STAGINGDIR/.config/nixpkgs"
ln -s "$DOTFILES/nix/nixpkgs/config.nix" "$STAGINGDIR/.config/nixpkgs/config.nix"

# NIXOS
if [ "$DISTRO" = "nixos" ]; then
    mkdir -p "$STAGINGDIR/.config/nixos"
    nixos_dir="$DOTFILES/nix/nixos-config/system"
    if [ "$EXECUTION_ENV" = "qemu" ]; then
        ln -s "$nixos_dir/configuration.nix" "$STAGINGDIR/.config/nixos/configuration.nix"
        ln -s "$nixos_dir/hardware-configuration.nix" "$STAGINGDIR/.config/nixos/hardware-configuration.nix"
    elif [ "$EXECUTION_ENV" = "baremetal" ] && [ "$MACHINE" = "htpc" ]; then
        ln -s "$nixos_dir/htpc/configuration.nix" "$STAGINGDIR/.config/nixos/configuration.nix"
        ln -s "$nixos_dir/htpc/hardware-configuration.nix" "$STAGINGDIR/.config/nixos/hardware-configuration.nix"
    else
        echo "ABORT! NixOS config not available for this environment:"
        print_env
        exit 1
    fi
    ln -s "$nixos_dir/base.nix" "$STAGINGDIR/.config/nixos/base.nix"
    ln -s "$nixos_dir/gui.nix" "$STAGINGDIR/.config/nixos/gui.nix"
    ln -s "$nixos_dir/overlays" "$STAGINGDIR/.config/nixos/overlays"
fi

# OTHER
ln -s "$DOTFILES/other/bin/exec-in-dir" "$STAGINGDIR/bin/exec-in-dir"
