#!/bin/sh

SCRIPTDIR="$( cd "$(dirname "$0")" || exit >/dev/null 2>&1 ; pwd -P )"

echo "DOTFILES_DISTRO=$DOTFILES_DISTRO"
echo "DOTFILES_CONTEXT=$DOTFILES_CONTEXT"
echo "DOTFILES_MACHINE=$DOTFILES_MACHINE"
echo "USER=$USER"
echo ""

# if [ -x "$(command -v lsb_release)" ]
# then
#     DOTFILES_DISTRO=$(lsb_release --id --short)
# else
#     echo "ABORT (lsb_release not found)"
#     exit 1
# fi

SOURCEDIR=${SOURCEDIR:-"$SCRIPTDIR/.deploy"}
TARGETDIR=${TARGETDIR:-"$HOME"}
echo "Deploying from $SOURCEDIR to $TARGETDIR"

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
