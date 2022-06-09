#!/usr/bin/env python3
import os

import i3init

TIMEOUT = 2.0

HOME = os.path.expanduser("~")

WORKSPACE_PROGRAMS = {
    # workspace
    "100:test": [
        # execstr, window_name, window_class, window_handling_commands
        [f"exec-in-dir {HOME}/dotfiles st -e sleep 2", "st-test", "st", None],
        # [f"code {HOME}/.config/vscode-workspaces/ziglings.code-workspace", "visual studio code", "code", None],
        # [f"code {HOME}/.config/vscode-workspaces/algorithms.code-workspace", "visual studio code", "code", None],
    ],
    # "200:dev": [
    #     ["st", "st-dev", "st", None],
    #     ["st", "st-dev", "st", None],
    # ],
}

i3init.run(WORKSPACE_PROGRAMS, TIMEOUT)
