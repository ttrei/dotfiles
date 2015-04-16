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

# Fetch all upstream branches (so you see their state with gitk --all)
git fetch --all -q

# Pull upstream `master`
echo -e "\n${Bld}${Gre}* Update master:${RCol}\n"
echo -e "${Gre}git checkout master:${RCol}"
git checkout master
echo -e "${Gre}git pull:${RCol}"
git pull

# Rebase local stuff on updated master
echo -e "\n${Bld}${Gre}* Rebase local changes on master:${RCol}\n"
echo -e "${Gre}git rebase master ${branch}:${RCol}"
git rebase master $branch
echo -e "${Gre}git push --force origin ${branch}:${RCol}"
git push --force origin $branch
