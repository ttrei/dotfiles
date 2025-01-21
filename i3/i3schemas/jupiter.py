#!/usr/bin/env python3
import os

from i3init import Program, Workspace

TIMEOUT = 5.0

HOME = os.path.expanduser("~")


I3SCHEMAS = {
    "init": [
        Workspace("05:notes").with_programs(
            Program(f"exec-in-dir {HOME}/dev/notes ghostty", commands=["move left"]),
            Program("emacs &", commands=["resize set width 70 ppt"]),
        ),
        Workspace("10:browser").with_programs(Program("firefox", commands=["layout tabbed"], timeout_extra_windows=2)),
    ],
    "dotfiles": [
        Workspace("85:dotfiles").with_programs(
            Program(f"exec-in-dir {HOME}/dotfiles ghostty", commands=["move left"]),
            Program(
                f"exec-in-dir {HOME}/dotfiles ghostty",
                commands=["split vertical", "layout stacking", "resize set width 70 ppt"],
            ),
        ),
    ],
    "homelab": [
        Workspace("20:dev").with_programs(
            Program(f"exec-in-dir {HOME}/dev/projects/homelab ghostty", commands=["move left"]),
            Program(
                f"exec-in-dir {HOME}/dev/projects/homelab ghostty",
                commands=["split vertical", "layout stacking", "resize set width 70 ppt"],
            ),
        ),
    ],
    "home-site": [
        Workspace("200:home-site-dev").with_programs(
            Program(f"exec-in-dir {HOME}/dev/projects/homelab/home_site ghostty", commands=["move left"]),
            Program(
                f"exec-in-dir {HOME}/dev/projects/homelab/home_site ghostty",
                commands=["split vertical", "layout stacking", "resize set width 70 ppt"],
            ),
        ),
        Workspace("201:home-site-browser").with_programs(
            Program(f"qutebrowser --config-py {HOME}/.config/qutebrowser/config-dev-home-site.py"),
        ),
    ],
    "algorithms": [
        Workspace("210:algorithms-doc").with_programs(
            Program("zathura /media/storage-new/Skiena-The_Algorithm_Design_Manual-2020.pdf"),
            Program("zathura /media/storage-new/ORourke-Computational_Geometry_in_C_2nd_Edition-1998.pdf"),
        ),
        Workspace("211:algorithms-dev").with_programs(
            Program(f"exec-in-dir {HOME}/dev/learn/zig/algorithms ghostty", commands=["move left"]),
            Program(
                f"exec-in-dir {HOME}/dev/learn/zig/algorithms ghostty",
                commands=["split vertical", "layout stacking", "resize set width 70 ppt"],
            ),
        ),
        # Workspace("212:algorithms-vscode").with_programs(
        #     Program(f"code {HOME}/.config/vscode-workspaces/algorithms.code-workspace"),
        # ),
    ],
    "handmade-pool": [
        Workspace("220:handmade-pool-dev").with_programs(
            Program(f"exec-in-dir {HOME}/dev/learn/zig/handmade_pool ghostty", commands=["move left", "move left"]),
            Program(
                f"exec-in-dir {HOME}/dev/learn/zig/zig_sdl_platform ghostty",
                commands=["split vertical", "layout stacking"],
            ),
            Program(
                f"exec-in-dir {HOME}/dev/learn/zig/handmade_pool ghostty",
                commands=["move right", "move left", "resize set width 70 ppt"],
            ),
        ),
    ],


    # "foodbook": I3SCHEMA_FOODBOOK,
    # "dev": I3SCHEMA_DEV,
    # "gamedev": I3SCHEMA_GAMEDEV,
    # "linux-programming-interface": I3SCHEMA_TLPI,
    # "tcp": I3SCHEMA_TCP,
    # "taukulis.lv": I3SCHEMA_TAUKULIS_LV,
    # "anki": I3SCHEMA_ANKI,
    # "saturn-qemu": I3SCHEMA_SATURN_QEMU,
    # "upgrade": I3SCHEMA_UPGRADE,
}

# DIR = f"{HOME}/dev/projects/foodbook"
# I3SCHEMA_FOODBOOK = {
#     "20:dev": [
#         [f"exec-in-dir {DIR} zutty".split(), "zutty-pool", "zutty", ["move left"]],
#         [
#             f"exec-in-dir {DIR} zutty".split(),
#             "zutty-pool",
#             "zutty",
#             ["move right", "move right", "split vertical", "layout stacking"],
#         ],
#         [
#             f"exec-in-dir {DIR} zutty".split(),
#             "zutty-pool",
#             "zutty",
#             ["move right", "resize set width 70 ppt"],
#         ],
#     ],
# }
#
#
# DIR = f"{HOME}/dev"
# I3SCHEMA_DEV = {
#     "20:dev": [
#         [f"exec-in-dir {DIR} zutty".split(), "zutty-dev", "zutty", ["move left"]],
#         [
#             f"exec-in-dir {DIR} zutty".split(),
#             "zutty-dev",
#             "zutty",
#             ["move right", "move right", "split vertical", "layout stacking"],
#         ],
#         [
#             f"exec-in-dir {DIR} zutty".split(),
#             "zutty-dev",
#             "zutty",
#             ["move right", "resize set width 70 ppt"],
#         ],
#     ],
# }
#
#
# DIR = f"{HOME}/dev/learn/godot"
# I3SCHEMA_GAMEDEV = {
#     "20:dev": [
#         [f"exec-in-dir {DIR} zutty".split(), "zutty-gamedev", "zutty", ["move left"]],
#         [
#             f"exec-in-dir {DIR} zutty".split(),
#             "zutty-gamedev",
#             "zutty",
#             ["move right", "move right", "split vertical", "layout stacking"],
#         ],
#         [
#             f"exec-in-dir {DIR} zutty".split(),
#             "zutty-gamedev",
#             "zutty",
#             ["move right", "resize set width 70 ppt"],
#         ],
#     ],
#     "22:godot": [
#         ["godot4".split(), "godot", "godot_engine", ["floating toggle", "layout tabbed"]],
#         ["firefox".split(), "mozilla firefox", "firefox", None],
#     ],
# }
#
#
# DEVDIR = f"{HOME}/dev/learn/tcp"
# BOOK = "/media/storage-new/Stevens-TCP_IP_Illustrated_Volume_1_The_Protocols_1994.pdf"
# BOOK2 = "/media/storage-new/books/LinuxProgrammingInterface.pdf"
# I3SCHEMA_TCP = {
#     "15:doc": [
#         [f"zathura {BOOK}", "org.pwmt.zathura".split(), "zathura", None],
#         [f"zathura {BOOK2}", "org.pwmt.zathura".split(), "zathura", None],
#     ],
#     "20:dev": [
#         [f"exec-in-dir {DEVDIR} zutty".split(), "zutty-tcp", "zutty", None],
#         [f"exec-in-dir {DEVDIR} zutty".split(), "zutty-tcp", "zutty", None],
#     ],
#     "65:wireshark": [
#         [f"wireshark".split(), "the wireshark network analyzer", "wireshark", None],
#     ],
# }
#
#
# DIR_TLPI = f"{HOME}/dev/learn/zig/linux_programming_interface"
# VSCODE_WORKSPACE_TLPI = f"{HOME}/.config/vscode-workspaces/linux_programming_interface.code-workspace"
# BOOK = "/media/storage-new/books/LinuxProgrammingInterface.pdf"
# I3SCHEMA_TLPI = {
#     "15:doc": [
#         [f"zathura {BOOK}".split(), "org.pwmt.zathura", "zathura", None],
#     ],
#     "20:dev": [
#         [f"exec-in-dir {DIR_TLPI} zutty".split(), "zutty-tlpi", "zutty", None],
#         [f"exec-in-dir {DIR_TLPI} zutty".split(), "zutty-tlpi", "zutty", None],
#     ],
#     "25:vscode": [
#         [f"code {VSCODE_WORKSPACE_TLPI}".split(), "visual studio code", "code", None],
#     ],
# }
#
#
# DIR = f"{HOME}/dev/projects/taukulis.lv"
# I3SCHEMA_TAUKULIS_LV = {
#     "20:dev": [
#         [
#             f"exec-in-dir {DIR} zutty".split(),
#             "zutty-taukulis.lv",
#             "zutty",
#             ["move left"],
#         ],
#         [
#             f"exec-in-dir {DIR} zutty".split(),
#             "zutty-taukulis.lv",
#             "zutty",
#             ["split vertical", "layout stacking", "resize set width 70 ppt"],
#         ],
#     ],
# }
#
#
# I3SCHEMA_ANKI = {
#     "69:anki": [
#         [["anki"], "anki", "anki", None],
#     ],
# }
#
#
# DIR = f"{HOME}/dotfiles/bootstrap/nixos-qemu"
# I3SCHEMA_SATURN_QEMU = {
#     "71:saturn-qemu": [
#         [f"exec-in-dir {DIR} zutty".split(), "zutty-saturn-qemu", "zutty", None],
#         [f"{DIR}/boot-qemu.sh".split(), "QEMU", "Qemu-system-x86_64", None],
#     ],
# }
#
#
# I3SCHEMA_UPGRADE = {
#     "95:upgrade": [
#         ["zutty".split(), "zutty-upgrade", "zutty", None],
#     ],
# }
