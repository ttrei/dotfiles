#!/usr/bin/env python3
import os

import initworkspace

TIMEOUT = 5.0

HOME = os.path.expanduser("~")
DIR = f"{HOME}/dev/learn/zig/handmade_pool"
VSCODE_WORKSPACE = f"{HOME}/.config/vscode-workspaces/handmade-pool.code-workspace"

WORKSPACE_PROGRAMS = {
    "20:dev": [
        [f"exec-in-dir {DIR} zutty", "zutty-pool", "zutty", None],
        [f"exec-in-dir {DIR} zutty", "zutty-pool", "zutty", None],
    ],
    "25:vscode": [
        [f"code {VSCODE_WORKSPACE}", "visual studio code", "code", None],
    ],
}

initworkspace.run(WORKSPACE_PROGRAMS, TIMEOUT)
