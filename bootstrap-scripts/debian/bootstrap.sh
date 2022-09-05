#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if ! id -nG "$USER" | grep -qw "sudo"; then
    echo "$USER does not belong to sudo group"
    exit 1
fi

LOGFILE="$HOME/bootstrap_$(date +%FT%H-%M-%S).log"
echo -e "Output will be written to logfile:\n$LOGFILE"
read -rp "Press Enter to continue" </dev/tty

# if grep -q "^flags.*\ hypervisor" /proc/cpuinfo; then
#     virtualbox=true
#     read -r -p "Make sure the VirtualBox Guest Additions CD is inserted and press any key..."
# else
#     virtualbox=false
#     mkdir -p /lib/firmware/amdgpu/
#     git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git \
#         /tmp/linux-firmware
#     cp /tmp/linux-firmware/amdgpu/vega20_*.bin /lib/firmware/amdgpu/
# fi

# `bash -x` needed to record commands+output of the called script
bash -x ./install_base.sh 2>&1 | tee "$LOGFILE"
# bash -x ./install_gui.sh 2>&1 | tee -a "$LOGFILE"
# bash -x ./install_additional_software.sh 2>&1 | tee -a "$LOGFILE"

# if [ "$virtualbox" != true ]; then
#     cp files/grub /etc/default/grub
#     update-grub
# fi

# if [ "$virtualbox" == true ]; then
#     ./setup_guest_additions.sh "$LOGFILE"
# fi

# bash -x ./setup_user_environment.sh 2>&1 | tee -a "$LOGFILE"
