#!/usr/bin/env bash

set -o errexit
set -o nounset

DOTFILES="$( cd "$(dirname "$0")/.." || exit >/dev/null 2>&1 ; pwd -P )"
STAGINGDIR=${DOTFILES_STAGINGDIR:-"$DOTFILES/.staging"}
ENVFILE=${DOTFILES_ENVFILE:-"$HOME/.dotfiles-env"}

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
if [ "$ARG" == "-v" ]; then
    echo "Found dotfiles config file: $ENVFILE"
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

mkdir -p "$STAGINGDIR/bin"
mkdir -p "$STAGINGDIR/.config"

# TERMINAL
mkdir -p "$STAGINGDIR/.config/htop"
mkdir -p "$STAGINGDIR/.config/htop"
mkdir -p "$STAGINGDIR/.config/xfce4/terminal"
if [ "$DISTRO" = "nixos" ]; then
    ln -s "$DOTFILES/terminal/bashrc" "$STAGINGDIR/.bashrc.legacy"
    ln -s "$DOTFILES/terminal/bash_nixos" "$STAGINGDIR/.bash_nixos"
    ln -s "$DOTFILES/terminal/profile" "$STAGINGDIR/.profile.legacy"
else
    ln -s "$DOTFILES/terminal/bash_profile" "$STAGINGDIR/.bash_profile"
    ln -s "$DOTFILES/terminal/bashrc" "$STAGINGDIR/.bashrc"
    ln -s "$DOTFILES/terminal/profile" "$STAGINGDIR/.profile"
fi
ln -s "$DOTFILES/terminal/bash_fzf" "$STAGINGDIR/.bash_fzf"
ln -s "$DOTFILES/terminal/bin/describe-environment.sh" "$STAGINGDIR/bin/describe-environment.sh"
ln -s "$DOTFILES/terminal/bin/fzf-search-contents.sh" "$STAGINGDIR/bin/fzf-search-contents.sh"
ln -s "$DOTFILES/terminal/bin/samecwd-terminal.sh" "$STAGINGDIR/bin/samecwd-terminal.sh"
ln -s "$DOTFILES/terminal/bin/unique-strings.sh" "$STAGINGDIR/bin/unique-strings.sh"
ln -s "$DOTFILES/terminal/dircolors" "$STAGINGDIR/.dircolors"
ln -s "$DOTFILES/terminal/envrc" "$STAGINGDIR/.envrc"
ln -s "$DOTFILES/terminal/git-prompt.sh" "$STAGINGDIR/.git-prompt.sh"
ln -s "$DOTFILES/terminal/htoprc" "$STAGINGDIR/.config/htop/htoprc"
ln -s "$DOTFILES/terminal/ignore" "$STAGINGDIR/.ignore"
ln -s "$DOTFILES/terminal/inputrc" "$STAGINGDIR/.inputrc"
ln -s "$DOTFILES/terminal/ripgreprc" "$STAGINGDIR/.ripgreprc"
ln -s "$DOTFILES/terminal/starship2.toml" "$STAGINGDIR/.config/starship2.toml"
ln -s "$DOTFILES/terminal/starship.toml" "$STAGINGDIR/.config/starship.toml"
ln -s "$DOTFILES/terminal/tmux.conf" "$STAGINGDIR/.tmux.conf"
ln -s "$DOTFILES/terminal/xfce4terminalrc" "$STAGINGDIR/.config/xfce4/terminal/terminalrc"
ln -s "$DOTFILES/terminal/z.lua/z.lua" "$STAGINGDIR/.z.lua"
ln -s "$DOTFILES/terminal/z/z.sh" "$STAGINGDIR/.z.sh"

mkdir -p "$STAGINGDIR/.bash_aliases"
ln -s "$DOTFILES/terminal/aliases/common" "$STAGINGDIR/.bash_aliases/common"
if [ "$DISTRO" = "debian" ] || [ "$DISTRO" = "ubuntu" ]; then
    ln -s "$DOTFILES/terminal/aliases/debian" "$STAGINGDIR/.bash_aliases/debian"
elif [ "$DISTRO" = "nixos" ]; then
    ln -s "$DOTFILES/terminal/aliases/nixos" "$STAGINGDIR/.bash_aliases/nixos"
fi
if [ "$CONTEXT" = "home" ]; then
    ln -s "$DOTFILES/terminal/aliases/home" "$STAGINGDIR/.bash_aliases/home"
elif [ "$CONTEXT" = "work" ]; then
    ln -s "$DOTFILES/terminal/aliases/work" "$STAGINGDIR/.bash_aliases/work"
fi

# SSH
mkdir -p "$STAGINGDIR/.ssh"
ln -s "$DOTFILES/ssh/config" "$STAGINGDIR/.ssh/config"
if [ "$CONTEXT" = "work" ]; then
    ln -sf "$DOTFILES/ssh/config-work" "$STAGINGDIR/.ssh/config"
fi

# GIT
mkdir -p "$STAGINGDIR/.config/git"
ln -s "$DOTFILES/git/bin/git-checkout-fzf.sh" "$STAGINGDIR/bin/git-checkout-fzf.sh"
ln -s "$DOTFILES/git/bin/git-commit-jira.sh" "$STAGINGDIR/bin/git-commit-jira.sh"
ln -s "$DOTFILES/git/bin/git-set-upstream.sh" "$STAGINGDIR/bin/git-set-upstream.sh"
ln -s "$DOTFILES/git/bin/rerere-train.sh" "$STAGINGDIR/bin/rerere-train.sh"
ln -s "$DOTFILES/git/config" "$STAGINGDIR/.config/git/config"
ln -s "$DOTFILES/git/gitignore" "$STAGINGDIR/.gitignore"
ln -s "$DOTFILES/git/gitk" "$STAGINGDIR/.config/git/gitk"
if [ "$CONTEXT" = "work" ]; then
    ln -s "$DOTFILES/git/config-work" "$STAGINGDIR/.config/git/config-work"
elif [ "$CONTEXT" = "home" ]; then
    ln -s "$DOTFILES/git/config-home" "$STAGINGDIR/.config/git/config-home"
fi
if [ "$DISTRO" = "nixos" ]; then
    ln -sf "$DOTFILES/git/gitk-nixos" "$STAGINGDIR/.config/git/gitk"
fi

# XORG
# TODO: $DOTFILES/xorg/Xresources-lenovo is unused
ln -s "$DOTFILES/xorg/bin/manage-desktop-displays.sh" "$STAGINGDIR/bin/manage-desktop-displays.sh"
ln -s "$DOTFILES/xorg/xbindkeysrc" "$STAGINGDIR/.xbindkeysrc"
ln -s "$DOTFILES/xorg/xmodmaprc-kinesis-advantage" "$STAGINGDIR/.xmodmaprc"
ln -s "$DOTFILES/xorg/xprofile" "$STAGINGDIR/.xprofile"
ln -s "$DOTFILES/xorg/Xresources" "$STAGINGDIR/.Xresources"
ln -s "$DOTFILES/xorg/xsessionrc" "$STAGINGDIR/.xsessionrc"
if [ "$MACHINE" = "htpc" ]; then
    ln -sf "$DOTFILES/xorg/xmodmaprc-standard-keyboards-kodi" "$STAGINGDIR/.xmodmaprc"
    ln -sf "$DOTFILES/xorg/xsessionrc-kodi" "$STAGINGDIR/.xsessionrc"
fi
if [ "$DISTRO" = "nixos" ]; then
    ln -sf "$DOTFILES/xorg/xprofile-nixos" "$STAGINGDIR/.xprofile"
    ln -sf "$DOTFILES/xorg/Xresources-nixos" "$STAGINGDIR/.Xresources"
fi
ln -s "$STAGINGDIR/.Xresources" "$STAGINGDIR/.Xdefaults"

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

# REDSHIFT
mkdir -p "$STAGINGDIR/.config/redshift"
ln -s "$DOTFILES/redshift/redshift.conf" "$STAGINGDIR/.config/redshift.conf"
ln -s "$DOTFILES/redshift/redshift.conf" "$STAGINGDIR/.config/redshift/redshift.conf"

# VSCODE
mkdir -p "$STAGINGDIR/.config/Code/User"
ln -s "$DOTFILES/vscode/settings.json" "$STAGINGDIR/.config/Code/User/settings.json"
ln -s "$DOTFILES/vscode/keybindings.json" "$STAGINGDIR/.config/Code/User/keybindings.json"
ln -s "$DOTFILES/vscode/workspaces" "$STAGINGDIR/.config/vscode-workspaces"

# VIM
mkdir -p "$STAGINGDIR/.config/nvim"
mkdir -p "$STAGINGDIR/.local/share/nvim/site"
mkdir -p "$STAGINGDIR/.vim"
ln -s "$DOTFILES/vim/after" "$STAGINGDIR/.vim/after"
ln -s "$DOTFILES/vim/ideavimrc" "$STAGINGDIR/.ideavimrc"
ln -s "$DOTFILES/vim/neovim/init.vim" "$STAGINGDIR/.config/nvim/init.vim"
ln -s "$DOTFILES/vim/neovim/pack" "$STAGINGDIR/.local/share/nvim/site/pack"
ln -s "$DOTFILES/vim/pack" "$STAGINGDIR/.vim/pack"
ln -s "$DOTFILES/vim/vimrc" "$STAGINGDIR/.vimrc"

# EMACS
mkdir -p "$STAGINGDIR/.config/doom"
ln -s "$DOTFILES/emacs/doom/config.el" "$STAGINGDIR/.config/doom/config.el"
ln -s "$DOTFILES/emacs/doom/init.el" "$STAGINGDIR/.config/doom/init.el"
ln -s "$DOTFILES/emacs/doom/packages.el" "$STAGINGDIR/.config/doom/packages.el"

# PYTHON
mkdir -p "$STAGINGDIR/.config/pip"
ln -s "$DOTFILES/python/pip.conf" "$STAGINGDIR/.config/pip/pip.conf"

# NIX
mkdir -p "$STAGINGDIR/.config/nix"
mkdir -p "$STAGINGDIR/.config/nixpkgs"
ln -s "$DOTFILES/nix/bin/apply-users.sh" "$STAGINGDIR/bin/apply-users.sh"
ln -s "$DOTFILES/nix/bin/update-user.sh" "$STAGINGDIR/bin/update-user.sh"
if [ "$DISTRO" = "nixos" ]; then
    ln -s "$DOTFILES/nix/bin/apply-system.sh" "$STAGINGDIR/bin/apply-system.sh"
    ln -s "$DOTFILES/nix/bin/update-system.sh" "$STAGINGDIR/bin/update-system.sh"
fi
ln -s "$DOTFILES/nix/nix.conf" "$STAGINGDIR/.config/nix/nix.conf"
ln -s "$DOTFILES/nix/nixpkgs/config.nix" "$STAGINGDIR/.config/nixpkgs/config.nix"

# HOME-MANAGER
mkdir -p "$STAGINGDIR/.config/home-manager"
hm_dir="$DOTFILES/nix/home-manager/"
if [ "$DISTRO" = "nixos" ]; then
    ln -s "$hm_dir/reinis/nixos.nix" "$STAGINGDIR/.config/home-manager/config.nix"
else
    ln -s "$hm_dir/reinis/non-nixos.nix" "$STAGINGDIR/.config/home-manager/config.nix"
fi
ln -s "$hm_dir/reinis/common.nix" "$STAGINGDIR/.config/home-manager/common.nix"
ln -s "$hm_dir/reinis/includes" "$STAGINGDIR/.config/home-manager/includes"
ln -s "$hm_dir/reinis/overlays" "$STAGINGDIR/.config/home-manager/overlays"

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

# K8S
mkdir -p "$STAGINGDIR/.config/k9s"
ln -s "$DOTFILES/k8s/k9s-skin-gruvbox-light.yml" "$STAGINGDIR/.config/k9s/skin.yml"

# MUSIC
mkdir -p "$STAGINGDIR/.config/beets"
mkdir -p "$STAGINGDIR/.config/navidrome"
ln -s "$DOTFILES/music/beets/config.yaml" "$STAGINGDIR/.config/beets/config.yaml"
ln -s "$DOTFILES/music/navidrome/navidrome.toml" "$STAGINGDIR/.config/navidrome/navidrome.toml"

# DUNST
mkdir -p "$STAGINGDIR/.config/dunst"
ln -s "$DOTFILES/dunst/dunstrc" "$STAGINGDIR/.config/dunst/dunstrc"

# LANGUAGE SERVERS
ln -s "$DOTFILES/language-servers/zls.json" "$STAGINGDIR/.config/zls.json"

# WEB
ln -s "$DOTFILES/web/userChrome.css" "$STAGINGDIR/.config/userChrome.css"

# CLANG-FORMAT
ln -s "$DOTFILES/clang-format/clang-format" "$STAGINGDIR/.clang-format"
ln -s "$DOTFILES/clang-format/clang-format.py" "$STAGINGDIR/.vim/clang-format.py"

# NETWORKING
if [ "$MACHINE" = "htpc" ]; then
    ln -s "$DOTFILES/net/bin/vpn-start.sh" "$STAGINGDIR/bin/vpn-start.sh"
    ln -s "$DOTFILES/net/bin/vpn-stop.sh" "$STAGINGDIR/bin/vpn-stop.sh"
    ln -s "$DOTFILES/net/bin/vpn-switch.sh" "$STAGINGDIR/bin/vpn-switch.sh"
fi

# OTHER
ln -s "$DOTFILES/other/bin/exec-in-dir" "$STAGINGDIR/bin/exec-in-dir"
ln -s "$DOTFILES/other/bin/get_remote_stats.py" "$STAGINGDIR/bin/get_remote_stats.py"
ln -s "$DOTFILES/other/bin/get_upgrade_counts.py" "$STAGINGDIR/bin/get_upgrade_counts.py"
ln -s "$DOTFILES/other/bin/steam-offline" "$STAGINGDIR/bin/steam-offline"
if [ "$CONTEXT" = "work" ]; then
    ln -s "$DOTFILES/other/bin/firefox-home" "$STAGINGDIR/bin/firefox-home"
fi
