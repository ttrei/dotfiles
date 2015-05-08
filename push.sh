#!/bin/bash

if [[ $HOSTNAME == "reinis-desktop" ]]; then
    branch="home-debian"
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


# Rebase local stuff on master
echo -e "\n${Bld}${Gre}* Rebase local changes on master:${RCol}\n"
echo -e "${Gre}git rebase master ${branch}:${RCol}"
git stash -q
git rebase master $branch
git stash pop -q

# Push
echo -e "\n${Bld}${Gre}* Push:${RCol}\n"
echo -e "${Gre}git push --force --all:${RCol}"
git push --force --all
