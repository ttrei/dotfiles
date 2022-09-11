#!/usr/bin/env sh

# Suppose we make a small change in how some dotfiles are deployed.
# E.g., we move some file from old-style to new-style in bin/stage.sh.
# This script verifies that the change doesn't affect output of bin/stage.sh for all configurations.

DIFFDIR=/tmp/dotfiles-staging-diff
STAGE_BASE=$DIFFDIR/stage-base
STAGE_CURRENT=$DIFFDIR/stage-current
mkdir -p $STAGE_BASE
mkdir -p $STAGE_CURRENT

CURRENT_DOTFILES="$( cd "$(dirname "$0")/.." || exit >/dev/null 2>&1 ; pwd -P )"
BASE_DOTFILES=/tmp/dotfiles-staging-diff/dotfiles-base
git worktree add --detach $BASE_DOTFILES $base_commit

BASE_CONFIGS=$DIFFDIR/base_configs
CURRENT_CONFIGS=$DIFFDIR/current_configs
ls $BASE_DOTFILES/configs | sort > $BASE_CONFIGS
ls $CURRENT_DOTFILES/configs | sort > $CURRENT_CONFIGS
common_configs=$(comm -12 $BASE_CONFIGS $CURRENT_CONFIGS)
uniq_base_configs=$(comm -23 $BASE_CONFIGS $CURRENT_CONFIGS)
uniq_current_configs=$(comm -13 $BASE_CONFIGS $CURRENT_CONFIGS)

pushd $BASE_DOTFILES
for config in $BASE_DOTFILES/configs:
    STAGINGDIR=/tmp/dotfiles-staging-diff/stage-base/$config \
    ENVFILE=$BASE_DOTFILES/configs/$config \
    $BASE_DOTFILES/bin/stage.sh
popd

pushd $CURRENT_DOTFILES
for config in $BASE_DOTFILES/configs:
    STAGINGDIR=/tmp/dotfiles-staging-diff/stage-base/$config \
    ENVFILE=$BASE_DOTFILES/configs/$config \
    $BASE_DOTFILES/bin/stage.sh
popd

git worktree remove dotfiles-base
