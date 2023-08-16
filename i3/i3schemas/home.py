#!/usr/bin/env python3
import os

import i3init
from rofi import Rofi

TIMEOUT = 5.0

HOME = os.path.expanduser("~")


I3SCHEMA_INIT = {
    "05:notes": [
        # execstr, window_name, window_class, window_handling_commands
        [f"exec-in-dir {HOME}/dev/notes zutty", "zutty-notes", "zutty", ["move left"]],
        ["emacs", "emacs-notes", "emacs", ["move right"]],
    ],
    "10:browser": [
        ["firefox", "mozilla firefox", "firefox", None],
    ],
}


I3SCHEMA_DOTFILES = {
    "85:dotfiles": [
        [f"exec-in-dir {HOME}/dotfiles zutty", "zutty-dotfiles", "zutty", None],
        [f"exec-in-dir {HOME}/dotfiles zutty", "zutty-dotfiles", "zutty", None],
    ],
}


DEVDIR = f"{HOME}/dev/learn/zig/algorithms"
VSCODE_WORKSPACE = f"{HOME}/.config/vscode-workspaces/algorithms.code-workspace"
BOOK = "/media/storage-new/Skiena-The_Algorithm_Design_Manual-2020.pdf"
BOOK2 = "/media/storage-new/ORourke-Computational_Geometry_in_C_2nd_Edition-1998.pdf"
I3SCHEMA_ALGORITHMS = {
    "15:doc": [
        [f"zathura {BOOK}", "org.pwmt.zathura", "zathura", None],
        [f"zathura {BOOK2}", "org.pwmt.zathura", "zathura", None],
    ],
    "20:dev": [
        [f"exec-in-dir {DEVDIR} zutty", "zutty-algorithms", "zutty", None],
        [f"exec-in-dir {DEVDIR} zutty", "zutty-algorithms", "zutty", None],
    ],
    "25:vscode": [
        [f"code {VSCODE_WORKSPACE}", "visual studio code", "code", None],
    ],
}


DIR = f"{HOME}/dev/learn/zig/handmade_pool"
DIR2 = f"{HOME}/dev/learn/zig/zig_sdl_platform"
VSCODE_WORKSPACE = f"{HOME}/.config/vscode-workspaces/handmade-pool.code-workspace"
I3SCHEMA_HANDMADE_POOL = {
    "20:dev": [
        [f"exec-in-dir {DIR} zutty", "zutty-pool", "zutty", None],
        [f"exec-in-dir {DIR2} zutty", "zutty-pool", "zutty", None],
    ],
    "25:vscode": [
        [f"code {VSCODE_WORKSPACE}", "visual studio code", "code", None],
    ],
}


DIR = f"{HOME}/dev/projects/foodbook"
I3SCHEMA_FOODBOOK = {
    "20:dev": [
        [f"exec-in-dir {DIR} zutty", "zutty-pool", "zutty", ["move left"]],
        [
            f"exec-in-dir {DIR} zutty",
            "zutty-pool",
            "zutty",
            ["move right", "move right", "split vertical", "layout stacking"],
        ],
        [f"exec-in-dir {DIR} zutty", "zutty-pool", "zutty", ["move right", "resize set width 70 ppt"]],
    ],
}


DEVDIR = f"{HOME}/dev/learn/tcp"
BOOK = "/media/storage-new/Stevens-TCP_IP_Illustrated_Volume_1_The_Protocols_1994.pdf"
BOOK2 = "/media/storage-new/books/LinuxProgrammingInterface.pdf"
I3SCHEMA_TCP = {
    "15:doc": [
        [f"zathura {BOOK}", "org.pwmt.zathura", "zathura", None],
        [f"zathura {BOOK2}", "org.pwmt.zathura", "zathura", None],
    ],
    "20:dev": [
        [f"exec-in-dir {DEVDIR} zutty", "zutty-tcp", "zutty", None],
        [f"exec-in-dir {DEVDIR} zutty", "zutty-tcp", "zutty", None],
    ],
    "65:wireshark": [
        [f"wireshark", "the wireshark network analyzer", "wireshark", None],
    ],
}


DIR_TLPI = f"{HOME}/dev/learn/zig/linux_programming_interface"
VSCODE_WORKSPACE_TLPI = f"{HOME}/.config/vscode-workspaces/linux_programming_interface.code-workspace"
BOOK = "/media/storage-new/books/LinuxProgrammingInterface.pdf"
I3SCHEMA_TLPI = {
    "15:doc": [
        [f"zathura {BOOK}", "org.pwmt.zathura", "zathura", None],
    ],
    "20:dev": [
        [f"exec-in-dir {DIR_TLPI} zutty", "zutty-tlpi", "zutty", None],
        [f"exec-in-dir {DIR_TLPI} zutty", "zutty-tlpi", "zutty", None],
    ],
    "25:vscode": [
        [f"code {VSCODE_WORKSPACE_TLPI}", "visual studio code", "code", None],
    ],
}


DIR = f"{HOME}/dev/projects/taukulis.lv"
VSCODE_WORKSPACE = f"{HOME}/.config/vscode-workspaces/taukulis.lv.code-workspace"
I3SCHEMA_TAUKULIS_LV = {
    "20:dev": [
        [f"exec-in-dir {DIR} zutty", "zutty-taukulis.lv", "zutty", None],
        [f"exec-in-dir {DIR} zutty", "zutty-taukulis.lv", "zutty", None],
    ],
    "25:vscode": [
        [f"code {VSCODE_WORKSPACE}", "visual studio code", "code", None],
    ],
}


DIR = f"{HOME}/dotfiles/bootstrap/nixos-qemu"
I3SCHEMA_QEMU_HTPC = {
    "71:htpc-qemu": [
        [f"exec-in-dir {DIR} zutty", "zutty-htpc-qemu", "zutty", None],
        [f"{DIR}/boot-qemu.sh", "QEMU", "Qemu-system-x86_64", None],
    ],
}


I3SCHEMA_UPGRADE = {
    "95:upgrade": [
        ["zutty", "zutty-upgrade", "zutty", None],
    ],
}


I3SCHEMAS = {
    "init": I3SCHEMA_INIT,
    "dotfiles": I3SCHEMA_DOTFILES,
    "algorithms": I3SCHEMA_ALGORITHMS,
    "handmade-pool": I3SCHEMA_HANDMADE_POOL,
    "foodbook": I3SCHEMA_FOODBOOK,
    "linux-programming-interface": I3SCHEMA_TLPI,
    "tcp": I3SCHEMA_TCP,
    "taukulis.lv": I3SCHEMA_TAUKULIS_LV,
    "qemu-htpc": I3SCHEMA_QEMU_HTPC,
    "upgrade": I3SCHEMA_UPGRADE,
}


def main(i3schemas):
    rofi = Rofi()
    options = list(i3schemas.keys())
    index, key = rofi.select("Select workspace configuration", options)
    if key == -1:  # Selection canceled
        return
    config_key = options[index]
    i3schemas = i3schemas[config_key]

    workspace = list(i3schemas.keys())[0]
    i3init.run_command(f"workspace {workspace}")
    i3init.run(i3schemas, TIMEOUT)


if __name__ == "__main__":
    main(I3SCHEMAS)
