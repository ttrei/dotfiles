#!/usr/bin/env python3
import asyncio

from i3ipc import Event
from i3ipc.aio import Connection
from i3ipc.events import WindowEvent

WORKSPACES = {
    "00:teams",
    "25:browser",
    "30:notes",
    "31:dev",
    "32:log",
    "35:idea",
    "36:vscode",
    "37:pycharm",
    "40:postman",
    "50:database",
    "51:kafka",
    "80:daemons",
    "90:audio",
    "95:upgrade",
    "96:home",
    "99:temporary",
}
QUEUE = asyncio.queues.Queue()


async def on_new_window(i3: Connection, e: WindowEvent):
    _ = i3
    name: str = e.container.name
    window_class: str = e.container.window_class

    print(f"{name=}, {window_class=}")

    global QUEUE
    if name.startswith("Microsoft Teams"):
        await e.container.command(f"move to workspace 00:teams")

    if QUEUE.empty():
        i3.main_quit()


async def main():
    i3 = await Connection(auto_reconnect=True).connect()
    global WORKSPACES
    existing_workspaces = await i3.get_workspaces()
    WORKSPACES -= {
        w.name for w in existing_workspaces
    }  # We will not touch already existing workspaces

    if len(WORKSPACES) == 0:
        return

    global QUEUE
    if "00:teams" in WORKSPACES:
        await asyncio.create_subprocess_exec("teams")
    QUEUE.put_nowait(1)

    i3.on(Event.WINDOW_NEW, on_new_window)
    await i3.main()


asyncio.run(main())
