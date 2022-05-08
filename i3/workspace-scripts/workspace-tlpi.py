#!/usr/bin/env python3
import os

import initworkspace

TIMEOUT = 5.0

HOME = os.path.expanduser("~")
DIR_TLPI = f"{HOME}/dev/learn/zig/linux_programming_interface"
VSCODE_WORKSPACE_TLPI = f"{HOME}/.config/vscode-workspaces/linux_programming_interface.code-workspace"
BOOK = "/media/storage-new/books/LinuxProgrammingInterface.pdf"

WORKSPACE_PROGRAMS = {
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

initworkspace.run(WORKSPACE_PROGRAMS, TIMEOUT)
