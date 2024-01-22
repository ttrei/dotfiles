#!/usr/bin/env python3
import os

import i3init

TIMEOUT = 2.0

HOME = os.path.expanduser("~")

WORKSPACE_PROGRAMS = {
    # workspace
    "100:test": [
        # exec_list, window_name, window_class, window_handling_commands
        [
            f"exec-in-dir {HOME}/dotfiles zutty -e sleep 3".split(),
            "zutty-test",
            "zutty",
            ["move left"],
        ],
        [
            f"exec-in-dir {HOME}/dotfiles zutty -e sleep 3".split(),
            "zutty-test",
            "zutty",
            ["move to workspace 101:test"],
        ],
        # [f"code {HOME}/.config/vscode-workspaces/ziglings.code-workspace".split(), "visual studio code", "code", None],
        # [f"code {HOME}/.config/vscode-workspaces/algorithms.code-workspace".split(), "visual studio code", "code", None],
    ],
    # "200:dev": [
    #     ["zutty".split(), "zutty-dev", "zutty", None],
    #     ["zutty".split(), "zutty-dev", "zutty", None],
    # ],
}

i3init.run(WORKSPACE_PROGRAMS, TIMEOUT)
