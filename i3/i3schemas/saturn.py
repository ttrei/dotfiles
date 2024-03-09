#!/usr/bin/env python3
import os

import click
import i3init

TIMEOUT = 5.0

HOME = os.path.expanduser("~")
DIR = f"{HOME}/dotfiles/bootstrap/nixos-qemu"

CONFIG = {
    "kodi": {
        "05:kodi": [
            # exec_list, window_name, window_class, window_handling_commands
            ["kodi".split(), "kodi", "kodi", None],
        ],
    },
    "firefox": {
        "10:firefox": [
            ["firefox".split(), "mozilla firefox", "firefox", None],
        ],
    },
    "chromium": {
        "15:chrome": [
            ["chromium".split(), None, "chromium-browser", None],
        ],
    },
    # NOTE: Spotify doesn't set window class or name until after it's started.
    "spotify": {
        "50:spotify": [
            ["spotify".split(), "spotify", "spotify", None],
        ],
    },
    "steam": {
        "90:steam": [
            [f"exec-in-dir {HOME} steam".split(), "steam", "steam", None],
        ],
    },
    # NOTE: If we don't use "exec-in-dir", Lutris gets killed when this script exits.
    "lutris": {
        "91:lutris": [
            [f"exec-in-dir {HOME} lutris".split(), "lutris", "lutris", None],
        ],
    },
    # TODO: Create a script for launching retroarch.
    # Previously I used this command: steam-offline -applaunch 1118310"
    # "retroarch": {
    #     "92:retroarch": [
    #         ["retroarch".split(), "retroarch", "retroarch", None],
    #     ],
    # },
}


@click.command()
@click.argument("program")
def main(program: str):
    if program not in CONFIG:
        raise ValueError(f"{program=} not found in config.")
    workspace = list(CONFIG[program].keys())[0]
    i3init.run_command(f"workspace {workspace}")
    i3init.run(CONFIG[program], TIMEOUT)


if __name__ == "__main__":
    main()
