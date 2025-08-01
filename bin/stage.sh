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
mkdir -p "$STAGINGDIR/.config/ncdu"
mkdir -p "$STAGINGDIR/.config/ghostty"
mkdir -p "$STAGINGDIR/.config/atuin"
if [ "$DISTRO" = "nixos" ] || [ "$MACHINE" == "mercury" ]; then
    ln -s "$DOTFILES/terminal/bashrc" "$STAGINGDIR/.bashrc.legacy"
    ln -s "$DOTFILES/terminal/bash_nixos" "$STAGINGDIR/.bash_nixos"
    ln -s "$DOTFILES/terminal/profile" "$STAGINGDIR/.profile.legacy"
else
    ln -s "$DOTFILES/terminal/bash_profile" "$STAGINGDIR/.bash_profile"
    ln -s "$DOTFILES/terminal/bashrc" "$STAGINGDIR/.bashrc"
    ln -s "$DOTFILES/terminal/profile" "$STAGINGDIR/.profile"
fi
ln -s "$DOTFILES/terminal/atuin/config.toml" "$STAGINGDIR/.config/atuin/config.toml"
ln -s "$DOTFILES/terminal/bash_fzf" "$STAGINGDIR/.bash_fzf"
ln -s "$DOTFILES/terminal/bin/describe-environment.sh" "$STAGINGDIR/bin/describe-environment.sh"
ln -s "$DOTFILES/terminal/bin/fzf-search-contents.sh" "$STAGINGDIR/bin/fzf-search-contents.sh"
ln -s "$DOTFILES/terminal/bin/start-terminal.sh" "$STAGINGDIR/bin/start-terminal.sh"
ln -s "$DOTFILES/terminal/bin/unique-strings.sh" "$STAGINGDIR/bin/unique-strings.sh"
ln -s "$DOTFILES/terminal/bin/rfv" "$STAGINGDIR/bin/rfv"
ln -s "$DOTFILES/terminal/dircolors" "$STAGINGDIR/.dircolors"
# ln -s "$DOTFILES/terminal/envrc" "$STAGINGDIR/.envrc"
ln -s "$DOTFILES/terminal/git-prompt.sh" "$STAGINGDIR/.git-prompt.sh"
ln -s "$DOTFILES/terminal/htoprc" "$STAGINGDIR/.config/htop/htoprc"
ln -s "$DOTFILES/terminal/ignore" "$STAGINGDIR/.ignore"
ln -s "$DOTFILES/terminal/inputrc" "$STAGINGDIR/.inputrc"
ln -s "$DOTFILES/terminal/bat" "$STAGINGDIR/.config/bat"
ln -s "$DOTFILES/terminal/ncdu" "$STAGINGDIR/.config/ncdu/config"
ln -s "$DOTFILES/terminal/ripgreprc" "$STAGINGDIR/.ripgreprc"
ln -s "$DOTFILES/terminal/starship2.toml" "$STAGINGDIR/.config/starship2.toml"
ln -s "$DOTFILES/terminal/starship.toml" "$STAGINGDIR/.config/starship.toml"
ln -s "$DOTFILES/terminal/tmux.conf" "$STAGINGDIR/.tmux.conf"
ln -s "$DOTFILES/terminal/xfce4terminalrc" "$STAGINGDIR/.config/xfce4/terminal/terminalrc"
if [ "$EXECUTION_ENV" = "wsl" ]; then
    ln -s "$DOTFILES/terminal/ghostty-wsl" "$STAGINGDIR/.config/ghostty/config"
    ln -s "$DOTFILES/terminal/bin/ghostty-wrapped" "$STAGINGDIR/bin/ghostty-wrapped"
else
    ln -s "$DOTFILES/terminal/ghostty" "$STAGINGDIR/.config/ghostty/config"
fi

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
    # shellcheck disable=SC1091
    os_release_codename=$(. /etc/os-release && echo "$VERSION_CODENAME")
    if [ "$DISTRO" = "debian" ] && [ "$os_release_codename" = "bullseye" ]; then
        # Debian 11 "bullseye" has openssh without the PubkeyAcceptedAlgorithms option
        true
    else
        ln -sf "$DOTFILES/ssh/config-work" "$STAGINGDIR/.ssh/config"
    fi
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
ln -s "$DOTFILES/git/config-work" "$STAGINGDIR/.config/git/config-work"
ln -s "$DOTFILES/git/config-home" "$STAGINGDIR/.config/git/config-home"
if [ "$DISTRO" = "nixos" ]; then
    ln -sf "$DOTFILES/git/gitk-nixos" "$STAGINGDIR/.config/git/gitk"
fi

# XORG
# TODO: $DOTFILES/xorg/Xresources-lenovo is unused
ln -s "$DOTFILES/xorg/bin/manage-desktop-displays.sh" "$STAGINGDIR/bin/manage-desktop-displays.sh"
ln -s "$DOTFILES/xorg/bin/detect_displays.sh" "$STAGINGDIR/bin/detect_displays.sh"
ln -s "$DOTFILES/xorg/xbindkeysrc" "$STAGINGDIR/.xbindkeysrc"
ln -s "$DOTFILES/xorg/xmodmaprc-kinesis-advantage" "$STAGINGDIR/.xmodmaprc"
ln -s "$DOTFILES/xorg/xprofile" "$STAGINGDIR/.xprofile"
ln -s "$DOTFILES/xorg/Xresources" "$STAGINGDIR/.Xresources"
ln -s "$DOTFILES/xorg/xsessionrc" "$STAGINGDIR/.xsessionrc"
if [ "$MACHINE" = "saturn" ]; then
    ln -sf "$DOTFILES/xorg/xsessionrc-htpc" "$STAGINGDIR/.xsessionrc"
    if [ "$EXECUTION_ENV" = "baremetal" ]; then
        ln -sf "$DOTFILES/xorg/xmodmaprc-standard-keyboards-htpc" "$STAGINGDIR/.xmodmaprc"
    fi
fi
if [ "$DISTRO" = "nixos" ]; then
    ln -sf "$DOTFILES/xorg/xprofile-nixos" "$STAGINGDIR/.xprofile"
    ln -sf "$DOTFILES/xorg/Xresources-nixos" "$STAGINGDIR/.Xresources"
fi
ln -s "$STAGINGDIR/.Xresources" "$STAGINGDIR/.Xdefaults"

# XDG
ln -s "$DOTFILES/xdg/user-dirs.conf" "$STAGINGDIR/.config/user-dirs.conf"
ln -s "$DOTFILES/xdg/user-dirs.dirs" "$STAGINGDIR/.config/user-dirs.dirs"

# I3/SWAY
mkdir -p "$STAGINGDIR/.config/i3"
mkdir -p "$STAGINGDIR/.config/i3blocks"
mkdir -p "$STAGINGDIR/.config/sway"
mkdir -p "$STAGINGDIR/bin/i3"
cp "$DOTFILES/i3/config/config" "$STAGINGDIR/.config/i3/config"
ln -s "$DOTFILES/i3/i3pyblocks" "$STAGINGDIR/.config/i3pyblocks"
ln -s "$DOTFILES/i3/sway/config" "$STAGINGDIR/.config/sway/config"
ln -s "$DOTFILES/i3/i3blocks/blocklets" "$STAGINGDIR/.config/i3blocks/blocklets"
ln -s "$DOTFILES/i3/commands.json" "$STAGINGDIR/.config/i3/commands.json"
ln -s "$DOTFILES/i3/bin/myrmidon/confirm.sh" "$STAGINGDIR/bin/confirm.sh"
ln -s "$DOTFILES/i3/bin/myrmidon/myrmidon.sh" "$STAGINGDIR/bin/myrmidon.sh"
ln -s "$DOTFILES/i3/i3schemas" "$STAGINGDIR/.config/i3schemas"
ln -s "$DOTFILES/i3/bin/i3-rename-current-workspace" "$STAGINGDIR/bin/i3/i3-rename-current-workspace"
ln -s "$DOTFILES/i3/bin/i3-schema-select" "$STAGINGDIR/bin/i3/i3-schema-select"
ln -s "$DOTFILES/i3/bin/i3-start" "$STAGINGDIR/bin/i3/i3-start"
ln -s "$DOTFILES/i3/bin/i3-workspaces" "$STAGINGDIR/bin/i3/i3-workspaces"
ln -s "$DOTFILES/i3/bin/i3-volume-control" "$STAGINGDIR/bin/i3/i3-volume-control"
if [ "$MACHINE" = "jupiter" ]; then
    if [ "$CONTEXT" = "home" ]; then
        ln -s "$DOTFILES/i3/workspaces/jupiter.txt" "$STAGINGDIR/.config/i3/workspaces.txt"
        ln -s "$DOTFILES/i3/sway/config-home" "$STAGINGDIR/.config/sway/config-home"
        cat "$DOTFILES/i3/config/config-home" >> "$STAGINGDIR/.config/i3/config"
    elif [ "$CONTEXT" = "work" ]; then
        ln -s "$DOTFILES/i3/workspaces/work.txt" "$STAGINGDIR/.config/i3/workspaces.txt"
    fi
elif [ "$MACHINE" = "mercury" ]; then
    ln -s "$DOTFILES/i3/workspaces/work.txt" "$STAGINGDIR/.config/i3/workspaces.txt"
elif [ "$MACHINE" = "saturn" ]; then
    ln -s "$DOTFILES/i3/workspaces/saturn.txt" "$STAGINGDIR/.config/i3/workspaces.txt"
    ln -s "$DOTFILES/i3/sway/config-htpc" "$STAGINGDIR/.config/sway/config-htpc"
    cat "$DOTFILES/i3/config/config-htpc" >> "$STAGINGDIR/.config/i3/config"
    ln -sf "$DOTFILES/i3/i3blocks/config-htpc" "$STAGINGDIR/.config/i3blocks/config"
    ln -sf "$DOTFILES/i3/commands-saturn.json" "$STAGINGDIR/.config/i3/commands.json"
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
mkdir -p "$STAGINGDIR/.vim"
ln -s "$DOTFILES/vim/after" "$STAGINGDIR/.vim/after"
ln -s "$DOTFILES/vim/ideavimrc" "$STAGINGDIR/.ideavimrc"
ln -s "$DOTFILES/vim/pack" "$STAGINGDIR/.vim/pack"
ln -s "$DOTFILES/vim/vimrc" "$STAGINGDIR/.vimrc"

# EMACS
mkdir -p "$STAGINGDIR/.config/doom"
ln -s "$DOTFILES/emacs/doom/config.el" "$STAGINGDIR/.config/doom/config.el"
ln -s "$DOTFILES/emacs/doom/init.el" "$STAGINGDIR/.config/doom/init.el"
ln -s "$DOTFILES/emacs/doom/packages.el" "$STAGINGDIR/.config/doom/packages.el"

# PYTHON
mkdir -p "$STAGINGDIR/.config/pip"
mkdir -p "$STAGINGDIR/.config/hatch"
mkdir -p "$STAGINGDIR/.config/ruff"
ln -s "$DOTFILES/python/pip.conf" "$STAGINGDIR/.config/pip/pip.conf"
ln -s "$DOTFILES/python/hatch/config.toml" "$STAGINGDIR/.config/hatch/config.toml"
ln -s "$DOTFILES/python/ruff.toml" "$STAGINGDIR/.config/ruff/ruff.toml"

# NIX
mkdir -p "$STAGINGDIR/.config/nix"
mkdir -p "$STAGINGDIR/.config/nixpkgs"
ln -s "$DOTFILES/nix/bin/apply-users.sh" "$STAGINGDIR/bin/apply-users.sh"
ln -s "$DOTFILES/nix/bin/expire-users-generations.sh" "$STAGINGDIR/bin/expire-users-generations.sh"

if [ "$DISTRO" = "nixos" ]; then
    ln -s "$DOTFILES/nix/bin/apply-system.sh" "$STAGINGDIR/bin/apply-system.sh"
    ln -s "$DOTFILES/nix/bin/cleanup-system.sh" "$STAGINGDIR/bin/cleanup-system.sh"
fi
ln -s "$DOTFILES/nix/nix.conf" "$STAGINGDIR/.config/nix/nix.conf"
ln -s "$DOTFILES/nix/nixpkgs/config.nix" "$STAGINGDIR/.config/nixpkgs/config.nix"


# K8S
ln -s "$DOTFILES/k8s/k9s" "$STAGINGDIR/.config/k9s"


# MUSIC
mkdir -p "$STAGINGDIR/.config/beets"
ln -s "$DOTFILES/music/beets/config.yaml" "$STAGINGDIR/.config/beets/config.yaml"

# DUNST
mkdir -p "$STAGINGDIR/.config/dunst"
ln -s "$DOTFILES/dunst/dunstrc" "$STAGINGDIR/.config/dunst/dunstrc"

# LANGUAGE SERVERS
ln -s "$DOTFILES/language-servers/zls/zls.json" "$STAGINGDIR/.config/zls.json"
mkdir -p "$STAGINGDIR/.config/clangd"
ln -s "$DOTFILES/language-servers/clangd/config.yaml" "$STAGINGDIR/.config/clangd/config.yaml"

# WEB
ln -s "$DOTFILES/web/userChrome.css" "$STAGINGDIR/.config/userChrome.css"
mkdir -p "$STAGINGDIR/.config/qutebrowser"
ln -s "$DOTFILES/web/qutebrowser/config-dev-home-site.py" "$STAGINGDIR/.config/qutebrowser/config-dev-home-site.py"

# CLANG-FORMAT
ln -s "$DOTFILES/clang-format/clang-format" "$STAGINGDIR/.clang-format"

# NETWORKING
if [ "$MACHINE" = "saturn" ]; then
    ln -s "$DOTFILES/net/bin/vpn-start.sh" "$STAGINGDIR/bin/vpn-start.sh"
    ln -s "$DOTFILES/net/bin/vpn-stop.sh" "$STAGINGDIR/bin/vpn-stop.sh"
    ln -s "$DOTFILES/net/bin/vpn-switch.sh" "$STAGINGDIR/bin/vpn-switch.sh"
fi

# TEXMACS
mkdir -p "$STAGINGDIR/.config/texmacs/progs"
ln -s "$DOTFILES/texmacs/my-init-texmacs.scm" "$STAGINGDIR/.config/texmacs/progs"

# LLM
mkdir -p "$STAGINGDIR/.config/io.datasette.llm"
ln -s "$DOTFILES/llm/io.datasette.llm/default_model.txt" "$STAGINGDIR/.config/io.datasette.llm/default_model.txt"
ln -s "$DOTFILES/llm/io.datasette.llm/aliases.json" "$STAGINGDIR/.config/io.datasette.llm/aliases.json"


# OTHER
ln -s "$DOTFILES/other/bin/exec-in-dir" "$STAGINGDIR/bin/exec-in-dir"
ln -s "$DOTFILES/other/bin/get_remote_stats.py" "$STAGINGDIR/bin/get_remote_stats.py"
ln -s "$DOTFILES/other/bin/get_upgrade_counts.py" "$STAGINGDIR/bin/get_upgrade_counts.py"
ln -s "$DOTFILES/other/bin/steam-offline" "$STAGINGDIR/bin/steam-offline"
if [ "$CONTEXT" = "work" ]; then
    ln -s "$DOTFILES/other/bin/firefox-home" "$STAGINGDIR/bin/firefox-home"
fi
