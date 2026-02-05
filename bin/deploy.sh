#!/usr/bin/env bash

set -o errexit
set -o nounset

DOTFILES="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
STAGINGDIR=${DOTFILES_STAGINGDIR:-"$DOTFILES/.staging"}
TARGETDIR=${DOTFILES_TARGETDIR:-"$HOME"}
ENVFILE=${DOTFILES_ENVFILE:-"$HOME/.dotfiles-env"}

ARG=${1:-}

"$DOTFILES"/bin/stage.sh "$ARG"

# shellcheck source=/dev/null
. "$ENVFILE"

echo "DEPLOYING $STAGINGDIR --> $TARGETDIR"

rm -rf "$TARGETDIR/.config/home-manager"
rm -rf "$TARGETDIR/.config/nixos"
rm -rf "$TARGETDIR/.vim"
rm -rf "$TARGETDIR/bin/i3/workspace-scripts"

cp --recursive --dereference --remove-destination "$STAGINGDIR/." "$TARGETDIR"

ln -sf "$DOTFILES/bin/apply-users.sh" "$TARGETDIR/bin/apply-users.sh"
if [ "$DISTRO" = "nixos" ]; then
    ln -sf "$DOTFILES/bin/apply-system.sh" "$TARGETDIR/bin/apply-system.sh"
fi

if [ -d "$TARGETDIR/.ssh" ]; then
    chmod 700 "$TARGETDIR/.ssh"
fi
if [ -f "$TARGETDIR/.ssh/config" ]; then
    chmod 600 "$TARGETDIR/.ssh/config"
fi

if [ "$DISTRO" != "nixos" ]; then
    echo -e "\nAdd the following hosts manually to /etc/hosts:"
    cat "$DOTFILES/net/hosts"
fi
