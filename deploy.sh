#!/bin/sh

SCRIPTDIR="$( cd "$(dirname "$0")" || exit >/dev/null 2>&1 ; pwd -P )"

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
    echo "ABORT! Couldn't select the old deployment directory."
    echo ""
    print_env
    exit 1
fi

SOURCEDIR=${SOURCEDIR:-"$SCRIPTDIR/.deploy-$OLD_DEPLOYMENT_NAME"}
TARGETDIR=${TARGETDIR:-"$HOME"}
echo "Deploying from $SOURCEDIR to $TARGETDIR"

if ! [ -d "$SOURCEDIR" ]; then
    echo "ABORT! Source directory $SOURCEDIR not found."
    exit 1
fi

# Different branches of this repo use different vim plugin mechanisms.
# Those different mechanisms expect plugins in different directories.
# Ensure that after deployment we have only those directories that we need.
rm -rf "$TARGETDIR/.vim"

rm -rf "$TARGETDIR/bin/i3/workspace-scripts"

cp --recursive \
    --dereference \
    --remove-destination \
    "$SOURCEDIR/." "$TARGETDIR"

# git does not allow .gitignore symlinks anymore:
# https://github.com/git/git/blob/master/Documentation/RelNotes/2.32.0.txt
# And it was ambiguous anyway - git thought that I'm using it to ignore stuff in
# the .deploy directory.
# Copy .gitignore explicitly.
cp "$SCRIPTDIR/git/gitignore" "$TARGETDIR/.gitignore"

if [ -d "$TARGETDIR/.ssh" ]; then
    chmod 700 "$TARGETDIR/.ssh"
fi
if [ -f "$TARGETDIR/.ssh/config" ]; then
    chmod 600 "$TARGETDIR/.ssh/config"
fi

if [ -d "$TARGETDIR/.config/i3/config.d" ]; then
    i3dir="$TARGETDIR/.config/i3"
    cp "$i3dir/config.d/config" "$i3dir/config"

    if test -n "$(find "$i3dir/config.d" -maxdepth 1 -name 'config-*' -print -quit)"
    # https://stackoverflow.com/a/4264351/9124671
    then
        cat "$i3dir"/config.d/config-* >> "$i3dir/config"
    fi

fi
