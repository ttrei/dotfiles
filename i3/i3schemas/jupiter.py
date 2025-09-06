#!/usr/bin/env python3
import os

from i3init import Program, Workspace

TIMEOUT = 5.0

HOME = os.path.expanduser("~")


I3SCHEMAS = {
    "init": [
        # Workspace("05:notes").with_programs(
        #     Program(f"exec-in-dir {HOME}/dev/notes ghostty", commands=["move left"]),
        #     Program("emacs &", commands=["resize set width 70 ppt"]),
        # ),
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
    "home.taukulis.lv": [
        Workspace("200:home.taukulis.lv-dev").with_programs(
            Program(f"exec-in-dir {HOME}/dev/projects/home.taukulis.lv ghostty", commands=["move left"]),
            Program(
                f"exec-in-dir {HOME}/dev/projects/home.taukulis.lv ghostty",
                commands=["split vertical", "layout stacking", "resize set width 70 ppt"],
            ),
        ),
        # Workspace("201:home.taukulis.lv-browser").with_programs(
        #     Program(f"qutebrowser --config-py {HOME}/.config/qutebrowser/config-dev-home-site.py"),
        # ),
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
    "networking": [
        Workspace("230:algorithms-doc").with_programs(
            Program(
                "zathura /media/storage-new/books/networking/TCP_IP-Illustrated-Volume1-The_Protocols-Richard_Stevens.pdf"
            ),
            Program("zathura /media/storage-new/books/networking/TCP_IP-Network_Administration-Craig_Hunt.epub"),
        ),
        Workspace("231:algorithms-dev").with_programs(
            Program(f"exec-in-dir {HOME}/dev/notes ghostty", commands=["move left"]),
            Program(
                f"exec-in-dir {HOME}/dev/notes ghostty",
                commands=["split vertical", "layout stacking", "resize set width 70 ppt"],
            ),
        ),
    ],
    "foodbook": [
        Workspace("20:dev").with_programs(
            Program(f"exec-in-dir {HOME}/dev/projects/foodbook ghostty", commands=["move left"]),
            Program(
                f"exec-in-dir {HOME}/dev/projects/foodbook ghostty",
                commands=["move right", "move right", "split vertical", "layout stacking"],
            ),
            Program(
                f"exec-in-dir {HOME}/dev/projects/foodbook ghostty", commands=["move right", "resize set width 70 ppt"]
            ),
        ),
    ],
    "dev": [
        Workspace("20:dev").with_programs(
            Program(f"exec-in-dir {HOME}/dev ghostty", commands=["move left"]),
            Program(
                f"exec-in-dir {HOME}/dev ghostty",
                commands=["move right", "move right", "split vertical", "layout stacking"],
            ),
            Program(f"exec-in-dir {HOME}/dev ghostty", commands=["move right", "resize set width 70 ppt"]),
        ),
    ],
    "gamedev": [
        Workspace("20:dev").with_programs(
            Program(f"exec-in-dir {HOME}/dev/learn/godot ghostty", commands=["move left"]),
            Program(
                f"exec-in-dir {HOME}/dev/learn/godot ghostty",
                commands=["move right", "move right", "split vertical", "layout stacking"],
            ),
            Program(f"exec-in-dir {HOME}/dev/learn/godot ghostty", commands=["move right", "resize set width 70 ppt"]),
        ),
        Workspace("22:godot").with_programs(
            Program("godot4", commands=["floating toggle", "layout tabbed"]), Program("firefox")
        ),
    ],
    "linux-programming-interface": [
        Workspace("15:doc").with_programs(Program("zathura /media/storage-new/books/LinuxProgrammingInterface.pdf")),
        Workspace("20:dev").with_programs(
            Program(f"exec-in-dir {HOME}/dev/learn/zig/linux_programming_interface ghostty"),
            Program(f"exec-in-dir {HOME}/dev/learn/zig/linux_programming_interface ghostty"),
        ),
        Workspace("25:vscode").with_programs(
            Program(f"code {HOME}/.config/vscode-workspaces/linux_programming_interface.code-workspace")
        ),
    ],
    "tcp": [
        Workspace("15:doc").with_programs(
            Program("zathura /media/storage-new/Stevens-TCP_IP_Illustrated_Volume_1_The_Protocols_1994.pdf"),
            Program("zathura /media/storage-new/books/LinuxProgrammingInterface.pdf"),
        ),
        Workspace("20:dev").with_programs(
            Program(f"exec-in-dir {HOME}/dev/learn/tcp ghostty"), Program(f"exec-in-dir {HOME}/dev/learn/tcp ghostty")
        ),
        Workspace("65:wireshark").with_programs(Program("wireshark")),
    ],
    "taukulis.lv": [
        Workspace("210:taukulis.lv-dev").with_programs(
            Program(f"exec-in-dir {HOME}/dev/projects/taukulis.lv ghostty", commands=["move left"]),
            Program(
                f"exec-in-dir {HOME}/dev/projects/taukulis.lv ghostty",
                commands=["split vertical", "layout stacking", "resize set width 70 ppt"],
            ),
        ),
    ],
    "anki": [
        Workspace("69:anki").with_programs(Program("anki")),
    ],
    "saturn-qemu": [
        Workspace("71:saturn-qemu").with_programs(
            Program(f"exec-in-dir {HOME}/dotfiles/bootstrap/nixos-qemu ghostty"),
            Program(f"{HOME}/dotfiles/bootstrap/nixos-qemu/boot-qemu.sh"),
        ),
    ],
    "upgrade": [
        Workspace("95:upgrade").with_programs(Program("ghostty")),
    ],
}
