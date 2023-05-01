#!/usr/bin/env python3
import os

import i3init
from rofi import Rofi

TIMEOUT = 5.0

HOME = os.path.expanduser("~")

I3SCHEMA_INIT = {
    "80:daemons": [
        ["zutty -e sudo openvpn --config /etc/openvpn/client/work.conf", "zutty-openvpn", "zutty", None],
    ],
    # "00:teams": [
    #     ["teams", "teams", "teams", None],
    # ],
    "25:browser": [
        ["firefox", "mozilla firefox", "firefox", None],
    ],
    "30:notes": [
        [f"exec-in-dir {HOME}/dev/doc zutty", "zutty-notes", "zutty", ["move left"]],
        [
            f"exec-in-dir {HOME}/dev/doc/modules/ROOT zutty -e nvim -p pages/todo.adoc pages/log.adoc",
            "zutty-dotfiles",
            "zutty",
            ["move right"],
        ],
    ],
    "31:dev": [
        [f"exec-in-dir {HOME}/ips/core zutty", "zutty-dev", "zutty", None],
        [f"exec-in-dir {HOME}/ips/core zutty", "zutty-dev", "zutty", None],
    ],
    "35:idea": [
        ["idea", "idea", "idea", None],
    ],
    "37:pycharm": [
        ["pycharm", "pycharm", "pycharm", None],
    ],
}


I3SCHEMA_DOTFILES = {
    "85:dotfiles": [
        [f"exec-in-dir {HOME}/dotfiles zutty", "zutty-dotfiles", "zutty", None],
        [f"exec-in-dir {HOME}/dotfiles zutty", "zutty-dotfiles", "zutty", None],
    ],
}


I3SCHEMA_UPGRADE = {
    "95:upgrade": [
        ["zutty", "zutty-upgrade", "zutty", None],
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
