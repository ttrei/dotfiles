#!/usr/bin/env python3

# NOTE(2025-01-22)
# Didn't update this script after refactoring i3init because i currently run linux at work.

import os

TIMEOUT = 5.0

HOME = os.path.expanduser("~")

# exec_list, window_name, window_class, window_handling_commands
I3SCHEMA_INIT = {
    "00:corp": [
        # TODO: The splash screen matches but then the main window gets created from scratch and
        # opens on current workspace.
        ["microsoft-edge".split(), None, "Microsoft-edge", None],
    ],
    "25:browser": [
        ["firefox".split(), "mozilla firefox", "firefox", None],
    ],
    "30:notes": [
        [
            f"exec-in-dir {HOME}/dev/doc zutty".split(),
            "zutty-notes",
            "zutty",
            ["move left"],
        ],
        [
            f"exec-in-dir {HOME}/dev/doc/modules/ROOT zutty -e nvim -p pages/todo.adoc pages/log.adoc".split(),
            "zutty-dotfiles",
            "zutty",
            ["resize set width 70 ppt"],
        ],
    ],
    "31:dev": [
        [
            f"exec-in-dir {HOME}/dev/repos/ips/ips-core zutty".split(),
            "zutty-dev",
            "zutty",
            ["move left"],
        ],
        [
            f"exec-in-dir {HOME}/dev/repos/ips/ips-core zutty".split(),
            "zutty-dev",
            "zutty",
            ["split vertical", "layout stacking", "resize set width 70 ppt"],
        ],
    ],
    "35:idea": [
        ["idea-community nosplash".split(), None, "jetbrains-idea-ce", None],
    ],
    "37:pycharm": [
        ["pycharm-community nosplash".split(), None, "jetbrains-pycharm-ce", None],
    ],
    "80:daemons": [
        [
            [
                *"zutty -e tmux -f /home/reinis/.tmux.conf new -sdaemons".split(),
                "sudo openvpn --config /etc/openvpn/client/work.conf",
            ],
            "zutty-openvpn",
            "zutty",
            None,
        ],
    ],
}


I3SCHEMA_DOTFILES = {
    "85:dotfiles": [
        [
            f"exec-in-dir {HOME}/dotfiles zutty".split(),
            "zutty-dotfiles",
            "zutty",
            ["move left"],
        ],
        [
            f"exec-in-dir {HOME}/dotfiles zutty".split(),
            "zutty-dotfiles",
            "zutty",
            ["split vertical", "layout stacking", "resize set width 70 ppt"],
        ],
    ],
}


I3SCHEMA_UPGRADE = {
    "95:upgrade": [
        ["zutty".split(), "zutty-upgrade", "zutty", None],
    ],
}


I3SCHEMAS = {
    "init": I3SCHEMA_INIT,
    "dotfiles": I3SCHEMA_DOTFILES,
    "upgrade": I3SCHEMA_UPGRADE,
}
