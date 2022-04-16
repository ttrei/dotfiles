#!/usr/bin/env python3
import os

import initworkspace

TIMEOUT = 2.0

HOME = os.path.expanduser("~")

WORKSPACE_PROGRAMS = {
    # workspace
    "100:test": [
        # execstr, window_name, window_class, window_handling_commands
        ["zutty -e sleep 1", "sleep", "zutty", None],
        # [f"code {HOME}/.config/vscode-workspaces/ziglings.code-workspace", "visual studio code", "code", None],
        # [f"code {HOME}/.config/vscode-workspaces/algorithms.code-workspace", "visual studio code", "code", None],
    ],
}

initworkspace.run(WORKSPACE_PROGRAMS, TIMEOUT)
