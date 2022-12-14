#!/usr/bin/env sh

# This script was created on 2022-12-14 from the official install script:
# curl -fsSL https://get.docker.com -o get-docker.sh
# DRY_RUN=1 sh get-docker.sh > install-docker.sh
# 
# Run this script with `sudo sh install-docker-debian-testing.sh`

# Using the latest stable release bullseye (Debian 11) because docker.com doesn't have repository
# for current Debian testing (bookworm)

# Uninstall previous docker installation:
# https://docs.docker.com/engine/install/debian/#uninstall-docker-engine

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates curl

mkdir -p /etc/apt/keyrings && chmod -R 0755 /etc/apt/keyrings
curl -fsSL "https://download.docker.com/linux/debian/gpg" | gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bullseye stable" > /etc/apt/sources.list.d/docker.list
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-compose-plugin \
    docker-scan-plugin
DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce-rootless-extras
