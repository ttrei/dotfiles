#!/usr/bin/env python3
import os

import initworkspace

TIMEOUT = 5.0

HOME = os.path.expanduser("~")
DEVDIR = f"{HOME}/dev/learn/zig/algorithms"
VSCODE_WORKSPACE = f"{HOME}/.config/vscode-workspaces/algorithms.code-workspace"
BOOK = "/media/storage-new/Skiena-The_Algorithm_Design_Manual-2020.pdf"

WORKSPACE_PROGRAMS = {
    "15:doc": [
        [f"zathura {BOOK}", "org.pwmt.zathura", "zathura", None],
    ],
    "20:dev": [
        [f"exec-in-dir {DEVDIR} zutty", "zutty-algorithms", "zutty", None],
        [f"exec-in-dir {DEVDIR} zutty", "zutty-algorithms", "zutty", None],
    ],
    "25:vscode": [
        [f"code {VSCODE_WORKSPACE}", "visual studio code", "code", None],
    ],
}

initworkspace.run(WORKSPACE_PROGRAMS, TIMEOUT)
