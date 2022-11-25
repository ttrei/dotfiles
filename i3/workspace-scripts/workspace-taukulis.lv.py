#!/usr/bin/env python3
import os

import i3init

TIMEOUT = 5.0

HOME = os.path.expanduser("~")
DIR = f"{HOME}/dev/projects/taukulis.lv"
VSCODE_WORKSPACE = f"{HOME}/.config/vscode-workspaces/taukulis.lv.code-workspace"

WORKSPACE_PROGRAMS = {
    "20:dev": [
        [f"exec-in-dir {DIR} zutty", "zutty-pool", "zutty", None],
        [f"exec-in-dir {DIR} zutty", "zutty-pool", "zutty", None],
    ],
    "25:vscode": [
        [f"code {VSCODE_WORKSPACE}", "visual studio code", "code", None],
    ],
}

i3init.run(WORKSPACE_PROGRAMS, TIMEOUT)
