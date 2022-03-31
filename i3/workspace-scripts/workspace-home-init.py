#!/usr/bin/env python3
import asyncio

from i3ipc import Event
from i3ipc.aio import Connection
from i3ipc.events import WindowEvent

WORKSPACES = {
    "05:notes": 2,
    "10:browser": 1,
    "20:dev": 2,
}


async def on_new_window(i3: Connection, e: WindowEvent):
    _ = i3
    name = e.container.name
    window_class = e.container.window_class

    print(f"on_new_window: {name=}, {window_class=}")

    if name in {"emacs-notes", "zutty-notes"}:
        workspace = "05:notes"
    elif window_class.lower() == "firefox":
        workspace = "10:browser"
    elif name == "zutty-dev":
        workspace = "20:dev"
    else:
        return

    await e.container.command(f"move to workspace {workspace}")

    if name == "emacs-notes":
        await e.container.command("move right")

    global WORKSPACES
    WORKSPACES[workspace] -= 1
    if WORKSPACES[workspace] == 0:
        WORKSPACES.pop(workspace)

    if len(WORKSPACES) == 0:
        # await asyncio.sleep(1)
        i3.main_quit()


async def main():
    i3 = await Connection(auto_reconnect=True).connect()
    global WORKSPACES
    # We will not touch already existing workspaces
    existing_workspaces = {w.name for w in await i3.get_workspaces()}
    WORKSPACES = {k: v for k, v in WORKSPACES.items() if k not in existing_workspaces}
    if len(WORKSPACES) == 0:
        return

    if "05:notes" in WORKSPACES:
        await asyncio.create_subprocess_exec("emacs", "--title=emacs-notes")
        await asyncio.create_subprocess_exec("zutty", "-t", "zutty-notes")
    if "10:browser" in WORKSPACES:
        await asyncio.create_subprocess_exec("firefox")
    if "20:dev" in WORKSPACES:
        await asyncio.create_subprocess_exec("zutty", "-t", "zutty-dev")
        await asyncio.create_subprocess_exec("zutty", "-t", "zutty-dev")

    i3.on(Event.WINDOW_NEW, on_new_window)
    await i3.main()


asyncio.run(main())
