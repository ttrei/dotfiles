#!/bin/sh

DOTFILES="$( cd "$(dirname "$0")" || exit >/dev/null 2>&1 ; pwd -P )"
STAGINGDIR="$DOTFILES/.staging"

print_env() {
    echo "DISTRO=$DISTRO"
    echo "CONTEXT=$CONTEXT"
    echo "MACHINE=$MACHINE"
    echo "EXECUTION_ENV=$EXECUTION_ENV"
    echo "USER=$USER"
}

if [ -z "$DISTRO" ] || [ -z "$CONTEXT" ] || [ -z "$MACHINE" ] || [ -z "$EXECUTION_ENV" ] || [ -z "$USER" ]; then
    echo "ABORT! Environment incomplete."
    echo ""
    print_env
    exit 1
fi

rm -rf "$STAGINGDIR"
echo "Staging to $STAGINGDIR"

################################################################################
# PREPARE DEPLOYMENT (old style, to be gradually migrated to new style)
################################################################################

if [ "$DISTRO" = "debian" ] && [ "$CONTEXT" = "home" ] && [ "$MACHINE" = "home-desktop" ]; then
    OLD_DEPLOYMENT_NAME="home-desktop-debian"
elif [ "$DISTRO" = "debian" ] && [ "$CONTEXT" = "work" ] && [ "$MACHINE" = "home-desktop" ]; then
    OLD_DEPLOYMENT_NAME="tieto2-desktop-debian"
elif [ "$DISTRO" = "debian" ] && [ "$CONTEXT" = "work" ] && [ "$MACHINE" = "work-laptop" ]; then
    OLD_DEPLOYMENT_NAME="tieto2-laptop-debian"
elif [ "$DISTRO" = "ubuntu" ] && [ "$CONTEXT" = "home" ] && [ "$MACHINE" = "htpc" ]; then
    OLD_DEPLOYMENT_NAME="kodi"
elif [ "$DISTRO" = "debian" ] && [ "$CONTEXT" = "home" ] && [ "$MACHINE" = "taukulis.lv" ]; then
    OLD_DEPLOYMENT_NAME="debian"
else
    echo "ABORT! Couldn't select the old-style deployment directory."
    echo ""
    print_env
    exit 1
fi
OLD_DEPLOYMENT_DIR="$DOTFILES/.deploy-$OLD_DEPLOYMENT_NAME"
echo "Selected old-style deployment directory: $OLD_DEPLOYMENT_DIR"
if ! [ -d "$OLD_DEPLOYMENT_DIR" ]; then
    echo "ABORT! Old-style deployment directory $OLD_DEPLOYMENT_DIR not found."
    exit 1
fi

cp --recursive \
    --dereference \
    "$OLD_DEPLOYMENT_DIR/." "$STAGINGDIR"

################################################################################
# PREPARE DEPLOYMENT (new style)
################################################################################

# GIT ######################

cp "$DOTFILES/git/gitignore" "$STAGINGDIR/.gitignore"

# SSH ######################

if [ -d "$STAGINGDIR/.ssh" ]; then
    chmod 700 "$STAGINGDIR/.ssh"
fi
if [ -f "$STAGINGDIR/.ssh/config" ]; then
    chmod 600 "$STAGINGDIR/.ssh/config"
fi

# I3/SWAY ##################

if [ -d "$STAGINGDIR/.config/i3/config.d" ]; then
    i3dir="$STAGINGDIR/.config/i3"
    cp "$i3dir/config.d/config" "$i3dir/config"

    if test -n "$(find "$i3dir/config.d" -maxdepth 1 -name 'config-*' -print -quit)"
    # https://stackoverflow.com/a/4264351/9124671
    then
        cat "$i3dir"/config.d/config-* >> "$i3dir/config"
    fi

fi
