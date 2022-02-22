#!/usr/bin/env python3
import asyncio
import pprint

from i3ipc import Event
from i3ipc.events import WindowEvent
from i3ipc.aio import Connection


async def on_new_window(i3: Connection, e: WindowEvent):
    print(f"a new window opened: {e.container.name}")
    pprint.pprint(e)
    pprint.pprint(e.ipc_data)
    pprint.pprint(e.container)
    pprint.pprint(e.change)
    tree = await i3.get_tree()
    idea_containers = tree.find_classed("jetbrains-idea")
    if idea_containers:
        idea = idea_containers[0]
        await idea.command("move to workspace 999:idea")

    pprint.pprint(idea_containers)


# There are multiple ways to launch an application:
# a) with an i3 command
#    https://i3wm.org/docs/userguide.html#exec
# b) with asyncio.create_subprocess_exec
#    https://docs.python.org/3.9/library/asyncio-subprocess.html#asyncio.create_subprocess_exec
# Which way is better?


async def main():
    i3 = await Connection(auto_reconnect=True).connect()
    workspaces = await i3.get_workspaces()
    for w in workspaces:
        print(w.ipc_data)

    await asyncio.create_subprocess_exec("idea")

    i3.on(Event.WINDOW_NEW, on_new_window)
    # i3.on(Event.WINDOW, on_window)
    await i3.main()


asyncio.run(main())
