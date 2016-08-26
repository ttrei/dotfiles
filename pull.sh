#!/usr/bin/env bash

if [[ $HOSTNAME == "reinis-desktop" ]]; then
    branch="home-debian"
elif [[ $HOSTNAME == "reinis-eeepc" ]]; then
    branch="home-eeepc"
elif [[ $HOSTNAME == "reinis-pi" ]]; then
    branch="home-pi"
elif [[ $HOSTNAME == "taukurei" ]]; then
    branch="work-centos6"
fi

# Colors
RCol='\e[0m'  # Reset
Bld='\e[1m'   # Bold
Red='\e[31m'  # Red
Gre='\e[32m'  # Green
Yel='\e[33m'  # Yellow
Blu='\e[34m'  # Light Blue


# Fetch upstream
echo -e "\n${Bld}${Gre}* Fetch upstream:${RCol}\n"
echo -e "${Gre}git fetch --all:${RCol}"
git fetch --all
echo -e "${Gre}git checkout master:${RCol}"
git checkout master
echo -e "${Gre}git merge origin/master:${RCol}"
git merge origin/master

# Rebase local stuff on updated master
echo -e "\n${Bld}${Gre}* Rebase local changes on master:${RCol}\n"
echo -e "${Gre}git rebase master ${branch}:${RCol}"
git stash -q
git rebase master $branch
git stash pop -q

# Update submodules
echo -e "\n${Bld}${Gre}* Update submodules:${RCol}\n"
echo -e "${Gre}git submodule init:${RCol}"
git submodule init
echo -e "${Gre}git submodule update:${RCol}"
git submodule update
