# dotfiles

## Structure

This repository is used to manage dotfiles for multiple machines. The files can
differ between machines. To manage the differences, each machine has its own
branch.

## Usage

## Add new VIM plugin

    cd vim/.vim/bundle/
    git submodule add <repo>
    # add ignore=dirty to .gitmodules and commit
