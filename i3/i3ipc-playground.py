#!/usr/bin/env python3
import asyncio

from i3ipc import Event
from i3ipc.events import WindowEvent
from i3ipc.aio import Connection


WINDOWNAME_WORKSPACE_MAP = {
    "zutty-dev1": "200:dev",
    "zutty-dev2": "200:dev",
    "emacs-dev": "200:dev",
}


WINDOWCLASS_WORKSPACE_MAP = {
    "jetbrains-idea-ce": "210:idea",
}


async def on_new_window(i3: Connection, e: WindowEvent):
    _ = i3
    name = e.container.name
    window_class = e.container.window_class
    if name in WINDOWNAME_WORKSPACE_MAP:
        await e.container.command(f"move to workspace {WINDOWNAME_WORKSPACE_MAP[name]}")
    if window_class in WINDOWCLASS_WORKSPACE_MAP:
        await e.container.command(
            f"move to workspace {WINDOWCLASS_WORKSPACE_MAP[window_class]}"
        )

    if name == "emacs-dev":
        await e.container.command("move left")

    # tree = await i3.get_tree()
    # idea_containers = tree.find_classed("jetbrains-idea")
    # if idea_containers:
    #     idea = idea_containers[0]
    #     await idea.command("move to workspace 999:idea")


# There are multiple ways to launch an application:
# a) with an i3 command
#    https://i3wm.org/docs/userguide.html#exec
# b) with asyncio.create_subprocess_exec
#    https://docs.python.org/3.9/library/asyncio-subprocess.html#asyncio.create_subprocess_exec
# Which way is better?

# How to populate a workspace with two columns, each consisting of vertically stacked windows?
# This could be useful: https://aduros.com/blog/hacking-i3-automatic-layout/


async def main():
    i3 = await Connection(auto_reconnect=True).connect()
    workspaces = await i3.get_workspaces()
    breakpoint()
    for w in workspaces:
        print(w.ipc_data)

    # await asyncio.create_subprocess_exec("idea")
    await asyncio.create_subprocess_exec("zutty", "-t", "zutty-dev1")
    # await asyncio.create_subprocess_exec("zutty", "-t", "zutty-dev2")
    # await asyncio.create_subprocess_exec("emacs", "--title=emacs-dev")
    # await i3.command("exec zutty")

    i3.on(Event.WINDOW_NEW, on_new_window)
    await i3.main()


asyncio.run(main())
