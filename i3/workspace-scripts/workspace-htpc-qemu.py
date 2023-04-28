#!/usr/bin/env python3
import os

import i3init

TIMEOUT = 5.0

HOME = os.path.expanduser("~")
DIR = f"{HOME}/dotfiles/bootstrap/nixos-qemu"

WORKSPACE_PROGRAMS = {
    "71:htpc-qemu": [
        [f"exec-in-dir {DIR} zutty", "zutty-htpc-qemu", "zutty", None],
        [f"{DIR}/boot-qemu.sh", "QEMU", "Qemu-system-x86_64", None],
    ],
}

i3init.run(WORKSPACE_PROGRAMS, TIMEOUT)
