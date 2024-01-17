#!/usr/bin/env python3
import os

import i3init
from rofi import Rofi

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
        [f"exec-in-dir {HOME}/dev/doc zutty".split(), "zutty-notes", "zutty", ["move left"]],
        [
            f"exec-in-dir {HOME}/dev/doc/modules/ROOT zutty -e nvim -p pages/todo.adoc pages/log.adoc".split(),
            "zutty-dotfiles",
            "zutty",
            ["resize set width 70 ppt"],
        ],
    ],
    "31:dev": [
        [f"exec-in-dir {HOME}/dev/repos/ips/ips-core zutty".split(), "zutty-dev", "zutty", ["move left"]],
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
        [[*"zutty -e tmux new -sdaemons".split(), "sudo openvpn --config /etc/openvpn/client/work.conf"], "zutty-openvpn", "zutty", None],
    ],
}


I3SCHEMA_DOTFILES = {
    "85:dotfiles": [
        [f"exec-in-dir {HOME}/dotfiles zutty".split(), "zutty-dotfiles", "zutty", ["move left"]],
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
