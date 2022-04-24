#!/usr/bin/env python3
import os

import initworkspace

TIMEOUT = 5.0

HOME = os.path.expanduser("~")
DIR_TLPI = f"{HOME}/dev/learn/zig/linux_programming_interface"
VSCODE_WORKSPACE_TLPI = f"{HOME}/.config/vscode-workspaces/linux_programming_interface.code-workspace"

WORKSPACE_PROGRAMS = {
    "20:dev": [
        [f"terminal-at-dir {DIR_TLPI}", "zutty-tlpi", "zutty", None],
        [f"terminal-at-dir {DIR_TLPI}", "zutty-tlpi", "zutty", None],
    ],
    "25:vscode": [
        [f"code {VSCODE_WORKSPACE_TLPI}", "visual studio code", "code", None],
    ],
}

initworkspace.run(WORKSPACE_PROGRAMS, TIMEOUT)
