#!/usr/bin/env bash

# Suppose we make a small change in how some dotfiles are deployed.
# E.g., we move some file from old-style to new-style in bin/stage.sh.
# This script shows how the change affects output of bin/deploy.sh for all configurations.

# "BASE" refers to the dotfiles repo state against which we will diff.
BASE_COMMIT=${1:-"HEAD"}

DIFFDIR=/tmp/dotfiles-diff
rm -rf "$DIFFDIR"
mkdir -p "$DIFFDIR"

DOTFILES_BASE="$DIFFDIR/dotfiles-base"
DOTFILES_CURRENT="$( cd "$(dirname "$0")/.." || exit >/dev/null 2>&1 ; pwd -P )"

# Checkout a separate worktree for the base version - we could have some uncommitted changes in the
# current worktree
git worktree add --quiet --detach "$DOTFILES_BASE" "$BASE_COMMIT"

# List configuration files in base and current dotfiles
BASE_CONFIGS_FILE=$DIFFDIR/base_configs
CURRENT_CONFIGS_FILE=$DIFFDIR/current_configs
find "$DOTFILES_BASE/configs" -type f -printf "%f\n" | sort > $BASE_CONFIGS_FILE
find "$DOTFILES_CURRENT/configs" -type f -printf "%f\n" | sort > $CURRENT_CONFIGS_FILE
common_configs=$(comm -12 $BASE_CONFIGS_FILE $CURRENT_CONFIGS_FILE)

# Deploy all the configs that are in common between base and current dotfiles.
DEPLOY_CURRENT="$DIFFDIR/deploye-current"
DEPLOY_BASE="$DIFFDIR/deploye-base"
mkdir -p "$DEPLOY_CURRENT"
mkdir -p "$DEPLOY_BASE"
while IFS= read -r config
do
    export DOTFILES_ENVFILE="$DOTFILES_BASE/configs/$config"
    export DOTFILES_TARGETDIR="$DEPLOY_BASE/$config"
    "$DOTFILES_BASE/bin/deploy.sh" > /dev/null

    export DOTFILES_ENVFILE="$DOTFILES_CURRENT/configs/$config"
    export DOTFILES_TARGETDIR="$DEPLOY_CURRENT/$config"
    "$DOTFILES_CURRENT/bin/deploy.sh" > /dev/null
done < <(echo "$common_configs")

# Do the diff
diff_cmd="diff -r $DEPLOY_BASE $DEPLOY_CURRENT"
diff_output="$($diff_cmd 2>&1 || true)"
if [ -n "$diff_output" ]; then
    echo -e "$diff_output\n" | less
fi

# Warn about configurations that are not common between base and current dotfiles
uniq_base_configs=$(comm -23 $BASE_CONFIGS_FILE $CURRENT_CONFIGS_FILE)
if [ -n "$uniq_base_configs" ]; then
    echo "Configurations present in base ($BASE_COMMIT) But not in current dotfiles:"
    echo "$uniq_base_configs"
fi
uniq_current_configs=$(comm -13 $BASE_CONFIGS_FILE $CURRENT_CONFIGS_FILE)
if [ -n "$uniq_current_configs" ]; then
    echo "Configurations present in current but not in base ($BASE_COMMIT) Dotfiles:"
    echo "$uniq_current_configs"
fi

git worktree remove dotfiles-base
rm -rf "$DIFFDIR"
