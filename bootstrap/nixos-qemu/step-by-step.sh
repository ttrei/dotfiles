#!/usr/bin/env bash

set -o errexit
set -o pipefail

source env.sh

GREEN='\033[0;32m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

function pause() {
    read -rsp $''
}

step_number=0
function step() {
    (( step_number = step_number + 1 ))
    echo -e "\n${GREEN}STEP $step_number: $1${NC}"
}

step "Create a new QEMU image"
echo "Execute this script:"
echo "$ $SCRIPT_DIR/create-new-qemu-image.sh"
pause

step "Set NixOS installer password"
echo "Execute on the guest system:"
echo "$ passwd # This is only a temporary password, use something simple"
pause

step "Upload and execute the install script"
echo "When prompted, use the password that you just set"
pause
ssh-keygen -f "/home/reinis/.ssh/known_hosts" -R "[localhost]:$QEMU_GUEST_PORT"
ssh -o StrictHostKeyChecking=no nixos@localhost -p $QEMU_GUEST_PORT <<'ENDSSH'
nix-env -iA nixos.git
git clone https://github.com/ttrei/dotfiles.git
sudo ~/dotfiles/bootstrap/nixos-qemu/install-nixos.sh
ENDSSH

step "Shut down the virtual machine"
echo "Execute on the guest system:"
echo "$ sudo systemctl poweroff"
pause

step "Boot the QEMU image"
echo "Execute this script:"
echo "$ $SCRIPT_DIR/boot-qemu.sh"
pause

ssh-keygen -f "/home/reinis/.ssh/known_hosts" -R "[localhost]:$QEMU_GUEST_PORT"

step "Set up home-manager and deploy dotfiles"
pause
ssh reinis@localhost -p $QEMU_GUEST_PORT <<'ENDSSH'
nix-channel --add https://github.com/nix-community/home-manager/archive/release-22.11.tar.gz home-manager
nix-channel --update
ENDSSH
# log out, as per home-manager install instructions
ssh -o StrictHostKeyChecking=no reinis@localhost -p $QEMU_GUEST_PORT <<'ENDSSH'
nix-shell '<home-manager>' -A install
git clone https://github.com/ttrei/dotfiles.git
cp ~/dotfiles/configs/home-desktop-nixos-qemu ~/.dotfiles-env
~/dotfiles/bin/deploy.sh
~/bin/update-user.sh
~/bin/apply-users.sh
ENDSSH

step "(optional) Switch to nixos-unstable channel"
echo "Execute these commands on the guest system:"
echo "$ sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos"
echo "$ update-system.sh"
echo "$ apply-system.sh"
echo "$ nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager"
echo "$ update-user.sh"
echo "$ apply-users.sh"
pause

# step "Generate SSH key and upload it to taukulis.lv"
# pause
# ssh -o StrictHostKeyChecking=no reinis@localhost -p $QEMU_GUEST_PORT <<'ENDSSH'
# # https://unix.stackexchange.com/a/135090
# [ ! -f ~/.ssh/id_rsa.pub ] && cat /dev/zero | ssh-keygen -q -N "" || exit 0
# ENDSSH
# scp -P $QEMU_GUEST_PORT \
#     reinis@localhost:.ssh/id_rsa.pub \
#     /var/tmp/nixos-qemu-id_rsa.pub
# ssh-copy-id -f -i /var/tmp/nixos-qemu-id_rsa.pub reinis@taukulis.lv
# rm /var/tmp/nixos-qemu-id_rsa.pub
