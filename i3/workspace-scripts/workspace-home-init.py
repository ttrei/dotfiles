#!/usr/bin/env python3
import asyncio

from i3ipc import Event
from i3ipc.aio import Connection
from i3ipc.events import WindowEvent

WORKSPACES = {
    "05:notes",
    "10:browser",
    "20:dev",
}
QUEUE = asyncio.queues.Queue()


async def on_new_window(i3: Connection, e: WindowEvent):
    _ = i3
    name = e.container.name
    window_class = e.container.window_class

    print(f"{name=}, {window_class=}")

    global QUEUE
    if name == "emacs-notes":
        await e.container.command(f"move to workspace 05:notes")
        await QUEUE.get()
    elif window_class == "Firefox":
        await e.container.command(f"move to workspace 10:browser")
        await QUEUE.get()
    elif name == "zutty-dev":
        await e.container.command(f"move to workspace 20:dev")
        await QUEUE.get()

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
    if "05:notes" in WORKSPACES:
        await asyncio.create_subprocess_exec("emacs", "--title=emacs-notes")
        QUEUE.put_nowait(1)
    if "10:browser" in WORKSPACES:
        await asyncio.create_subprocess_exec("firefox")
        QUEUE.put_nowait(1)
    if "20:dev" in WORKSPACES:
        await asyncio.create_subprocess_exec("zutty", "-t", "zutty-dev")
        QUEUE.put_nowait(1)
        await asyncio.create_subprocess_exec("zutty", "-t", "zutty-dev")
        QUEUE.put_nowait(1)

    i3.on(Event.WINDOW_NEW, on_new_window)
    await i3.main()


asyncio.run(main())
