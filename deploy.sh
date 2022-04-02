#!/bin/sh

SCRIPTDIR="$( cd "$(dirname "$0")" || exit >/dev/null 2>&1 ; pwd -P )"
SOURCEDIR=${SOURCEDIR:-"$SCRIPTDIR/.deploy"}
TARGETDIR=${TARGETDIR:-"$HOME"}

echo "Deploying from $SOURCEDIR to $TARGETDIR"

# TODO Improve the deployment mechanism.
# Vision:
# 1. Detect where we are deploying (which OS, which machine, home or work).
#    Store this info in env variables.
# 2. Select the correct old-style symlink tree directory based on the above.
# 3. Copy the symlink tree to a temporary directory.
# 4. Add additional stuff to the temporary directory. Intention is to gradually migrate configs from
#    the old-style symlink tree.
# 5a. Deploy the temp directory to $HOME.
# or
# 5b. Show a diff between current $HOME state and the temp directory.

# Different branches of this repo use different vim plugin mechanisms.
# Those different mechanisms expect plugins in different directories.
# Ensure that after deployment we have only those directories that we need.
rm -rf "$TARGETDIR/.vim"

rm -rf "$TARGETDIR/bin/i3/workspace-scripts"

cp -rL --remove-destination "$SOURCEDIR/." "$TARGETDIR"

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
