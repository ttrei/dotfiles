#!/usr/bin/env python3
# https://i3pyblocks.readthedocs.io/en/latest/creating-a-new-block.html
# https://i3pyblocks.readthedocs.io/en/latest/autoapi/index.html
# https://github.com/thiagokokada/i3pyblocks/blob/master/example.py


import asyncio
import json
import logging
import signal
import socket
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional, Tuple

import psutil
from i3pyblocks import Runner, blocks, types, utils
from i3pyblocks._internal import misc
from i3pyblocks.blocks import datetime as datetime_block
from i3pyblocks.blocks import inotify, ps, pulse

# from i3pyblocks.blocks import dbus, http, x11

logging.basicConfig(filename=Path.home().joinpath(".i3pyblocks.log"), level=logging.INFO)


class RemoteSummaryBlock(blocks.PollingBlock):
    def __init__(self, hostname: str, path: str, sleep: int = 5, **kwargs) -> None:
        super().__init__(sleep=sleep, **kwargs)
        self.hostname = hostname
        self.path = path

    def get_summary(self) -> Tuple[str, str, Optional[str]]:
        try:
            f = open(self.path, "r")
            strdata = f.read()
            f.close()
        except IOError:
            logging.error(f"Could not read {self.path}")
            return "", "", types.Color.NEUTRAL

        try:
            data = json.loads(strdata)
        except ValueError:
            logging.error(f"{self.path} contains invalid JSON")
            return "", "", types.Color.NEUTRAL

        host_data = data.get(self.hostname)
        if host_data is None:
            logging.error(f"{self.hostname} not in {self.path}")
            return "", "", types.Color.NEUTRAL

        if "error" in host_data:
            return host_data["error"], host_data["error"][:5], types.Color.URGENT

        try:
            upgrades = host_data["upgrades"]
            space = host_data["space"]
            memory = host_data["memory"]
        except KeyError as e:
            logging.error(f"{e} not in {self.path}[{self.hostname}]")
            return "", "", types.Color.NEUTRAL

        full_text = ""
        short_text = ""
        color = None

        upgrade_count = upgrades["count"]
        if upgrade_count > 0:
            full_text += f" upgrades({upgrade_count})"
            short_text += f" u({upgrade_count})"
            color = types.Color.WARN

        low_space = []
        for mountpoint in space:
            size = space[mountpoint]["size"]
            available = space[mountpoint]["available"]
            if size == 0:
                continue
            percent = available / size * 100
            if available < 1024 and percent < 5:
                low_space.append(mountpoint)
        if low_space:
            low_space = " ".join(low_space)
            full_text += f" space({low_space})"
            short_text += " space"
            color = types.Color.WARN

        memtotal = memory["total"]
        memavail = memory["available"]
        swaptotal = memory["swap_total"]
        swapfree = memory["swap_free"]
        percent = memavail / memtotal * 100
        if percent < 5:
            full_text += f" memory({memavail}M/{memtotal}M)"
            short_text += " mem"
            color = types.Color.WARN
        if swaptotal > 0 and swaptotal - swapfree > 1024:
            full_text += f" swapping({swaptotal - swapfree}M)"
            short_text += " swap"
            color = types.Color.WARN

        mtime = datetime.fromisoformat(host_data["mtime"])
        now = datetime.fromtimestamp(time.time(), tz=timezone.utc)
        if (now - mtime).total_seconds() > 300:
            color = "#444444"  # dark gray

        if full_text:
            full_text = f"{self.hostname:}{full_text}"
            short_text = f"{self.hostname[:1]:}{short_text}"

        return full_text, short_text, color

    async def run(self) -> None:
        full_text, short_text, color = self.get_summary()
        self.update(
            full_text=full_text,
            short_text=short_text,
            color=color,
        )


class UpgradeCountBlock(blocks.PollingBlock):
    def __init__(self, hostname: str, path: str, sleep: int = 5, **kwargs) -> None:
        super().__init__(sleep=sleep, **kwargs)
        self.hostname = hostname
        self.path = path

    def get_upgrade_count(self) -> int:
        try:
            f = open(self.path, "r")
            strdata = f.read()
            f.close()
        except IOError:
            # logging.error(f"Could not read {self.path}")
            return -1

        try:
            data = json.loads(strdata)
        except ValueError:
            logging.error(f"{self.path} contains invalid JSON")
            return -1

        by_host = {x["host"]: x for x in data}
        host_data = by_host.get(self.hostname)
        if host_data is None:
            logging.error(f"{self.hostname} not in {self.path}")
            return -1

        return int(host_data.get("count", -1))

    async def run(self) -> None:
        count = self.get_upgrade_count()
        if count == 0:
            self.update()  # hide the block
            return
        elif count > 0:
            color = types.Color.WARN
        else:
            color = types.Color.URGENT
        self.update(
            f"upgrades: {count}",
            color=color,
        )


class CustomNetworkSpeedBlock(ps.NetworkSpeedBlock):
    """Custom formatting to keep the block width constant"""

    # TODO: Is it possible to modify NetworkSpeedBlock to accept the format as parameter?

    @staticmethod
    def bytes2human(n, format="%(value).1f%(symbol)s"):
        """Copied from psutil._common and adjusted to make "K" the lowest unit."""
        symbols = ("K", "M", "G")
        prefix = {}
        for i, s in enumerate(symbols):
            prefix[s] = 1 << (i + 1) * 10
        for symbol in reversed(symbols):
            if symbol == "K" or n >= prefix[symbol]:
                value = float(n) / prefix[symbol]
                _ = value
                return format % locals()

    @staticmethod
    def format_speed(value: int):
        """Optimized to keep the string constant"""
        if value < 10 * (2**10):  # < 10 KiB/s
            # from "0.0K" to "9.9K"
            return CustomNetworkSpeedBlock.bytes2human(value, format="%(value).1f%(symbol)s")
        elif value < 2**20:  # < 1 MiB/s
            # from " 10K" to "999K"
            return CustomNetworkSpeedBlock.bytes2human(value, format="%(value)3d%(symbol)s")
        else:
            # from "1.0M"
            return CustomNetworkSpeedBlock.bytes2human(value, format="%(value).1f%(symbol)s")

    async def run(self) -> None:
        self.interface = self._find_interface(self.interface)

        if not self.interface:
            self.update(self.format_down, color=types.Color.URGENT)
            return

        now = psutil.net_io_counters(pernic=True)
        now_time = time.time()

        if self.interface in now.keys():
            upload, download = self._calculate_speed(
                self.previous[self.interface],
                self.previous_time,
                now[self.interface],
                now_time,
            )
        else:
            upload, download = 0, 0

        color = misc.calculate_threshold(self.colors, max(upload, download))

        self.update(
            self.ex_format(
                self.format_up,
                upload=self.format_speed(int(upload)),
                download=self.format_speed(int(download)),
                interface=self.interface,
            ),
            color=color,
        )

        self.previous = now
        self.previous_time = now_time


class WireguardBlock(blocks.PollingBlock):
    r"""Block that shows if Wireguard VPN is currently enabled

    :param interface: Network interface of the VPN

    :param sleep: Sleep in seconds between each call to
        :meth:`~i3pyblocks.blocks.base.PollingBlock.run()`.

    :param \*\*kwargs: Extra arguments to be passed to
        :class:`~i3pyblocks.blocks.base.PollingBlock` class.
    """

    def __init__(self, interface: str, sleep: int = 3, **kwargs) -> None:
        super().__init__(sleep=sleep, **kwargs)
        self.interface = interface

    async def run(self) -> None:
        stats = psutil.net_if_stats().get(self.interface)
        if stats is None or not stats.isup:
            self.update("VPN off", color=types.Color.URGENT)
        else:
            self.update("VPN on", color=types.Color.NEUTRAL)


def get_partitions(excludes={"/boot", "/nix", "/snap", "/var/snap"}):
    partitions = psutil.disk_partitions()
    return [p for p in partitions if not any(p.mountpoint.startswith(e) for e in excludes)]


async def main():
    runner = Runner()

    hostname = socket.gethostname()

    # # FIXME
    # # Upgrade count
    # await runner.register_block(
    #     UpgradeCountBlock(
    #         hostname=hostname,
    #         path="/var/tmp/upgrade_counts.json",
    #     )
    # )

    # Summary of remote machines
    if hostname == "jupiter":
        await runner.register_block(RemoteSummaryBlock(hostname="neptune", path="/var/tmp/remote-summary.json"))
        await runner.register_block(RemoteSummaryBlock(hostname="saturn", path="/var/tmp/remote-summary.json"))

    # Current network speed for either en* (ethernet) or wl* devices.
    await runner.register_block(
        CustomNetworkSpeedBlock(
            format_up="{interface}  {download}  {upload}",
            format_down="",
            interface_regex="en*|wl*",
        )
    )

    if hostname in {"saturn", "saturn-qemu"}:
        # VPN status
        await runner.register_block(WireguardBlock(interface="wg-mullvad"))

    # For each partition found, add it to the Runner
    # Using `{{short_path}}` shows only the first letter of the path
    # e.g., /mnt/backup -> /m/b
    for partition in get_partitions():
        await runner.register_block(
            ps.DiskUsageBlock(
                format=" {short_path} {free:.1f}G",
                path=partition.mountpoint,
                colors={
                    0: types.Color.NEUTRAL,
                    80: types.Color.WARN,
                    95: types.Color.URGENT,
                },
            )
        )

    await runner.register_block(ps.VirtualMemoryBlock(format=" {available:.1f}G"))

    # Using custom icons to show the temperature visually
    # So when the temperature is above 75,  is shown, when it is above 50,
    #  is shown, etc
    # Needs Font Awesome 5 installed
    await runner.register_block(
        ps.SensorsTemperaturesBlock(
            format="{icon} {current:.0f}°C",
            icons={
                0: "",
                25: "",
                50: "",
                75: "",
            },
        )
    )

    await runner.register_block(
        ps.CpuPercentBlock(
            format=" {percent:4.1f}%",
            colors={
                0: types.Color.NEUTRAL,
                10: types.Color.WARN,
                50: types.Color.URGENT,
            },
        ),
    )

    # Load only makes sense depending of the number of CPUs installed in
    # machine, so get the number of CPUs here and calculate the color mapping
    # dynamically
    cpu_count = psutil.cpu_count()
    await runner.register_block(
        ps.LoadAvgBlock(
            format=" {load1:.2f}",
            colors={
                0: types.Color.NEUTRAL,
                cpu_count / 2: types.Color.WARN,
                cpu_count: types.Color.URGENT,
            },
        ),
    )

    if psutil.sensors_battery() is not None:
        await runner.register_block(
            ps.SensorsBatteryBlock(
                format_plugged=" {percent:.0f}%",
                format_unplugged="{icon} {percent:.0f}% {remaining_time}",
                format_unknown="{icon} {percent:.0f}%",
                icons={
                    0: "",
                    10: "",
                    25: "",
                    50: "",
                    75: "",
                },
            )
        )

    # Simulate the popular Caffeine extension from Gnome and macOS.
    # await runner.register_block(
    #     x11.CaffeineBlock(
    #         format_on="  ",
    #         format_off="  ",
    #     )
    # )

    # KbddBlock uses D-Bus to get the keyboard layout information updates, so
    # it is very efficient (i.e.: there is no polling). But it needs `kbdd`
    # installed and running: https://github.com/qnikst/kbdd
    # Using mouse buttons or scroll here allows you to cycle between the layouts
    # By default the resulting string is very big (i.e.: 'English (US, intl.)'),
    # so we lowercase it using '!l' and truncate it to the first two letters
    # using ':.2s', resulting in `en`
    # You could also use '!u' to UPPERCASE it instead
    # await runner.register_block(
    #     dbus.KbddBlock(
    #         format=" {full_layout!l:.2s}",
    #     )
    # )

    # MediaPlayerBlock listen for updates in your player (in this case Spotify)
    # await runner.register_block(dbus.MediaPlayerBlock(player="spotify"))

    # In case of `kbdd` isn't available for you, here is a alternative using
    # ShellBlock and `xkblayout-state` program.  ShellBlock just show the output
    # of `command` (if it is empty this block is hidden)
    # `command_on_click` runs some command when the mouse click is captured,
    # in this case when the user scrolls up or down
    # await runner.register_block(
    #     shell.ShellBlock(
    #         command="xkblayout-state print %s",
    #         format=" {output}",
    #         command_on_click={
    #             types.MouseButton.SCROLL_UP: "xkblayout-state set +1",
    #             types.MouseButton.SCROLL_DOWN: "xkblayout-state set -1",
    #         },
    #     )
    # )

    # By default BacklightBlock showns a message "No backlight found" when
    # there is no backlight
    # We set to empty instead, so when no backlight is available (i.e.
    # desktop), we hide this block
    await runner.register_block(
        inotify.BacklightBlock(
            format=" {percent:.0f}%",
            format_no_backlight="",
            command_on_click={
                types.MouseButton.SCROLL_UP: "light -A 5%",
                types.MouseButton.SCROLL_DOWN: "light -U 5",
            },
        )
    )

    # `signals` allows us to send multiple signals that this block will
    # listen and do something
    # In this case, we can force update the module when the volume changes,
    # for example, by running:
    # $ pactl set-sink-volume @DEFAULT_SINK@ +5% && pkill -SIGUSR1 example.py
    await runner.register_block(
        pulse.PulseAudioBlock(
            format=" {volume:.0f}%",
            format_mute=" mute",
        ),
        signals=(signal.SIGUSR1, signal.SIGUSR2),
    )

    # RequestsBlock do a HTTP request to an url. We are using it here to show
    # the current weather for location, using
    # https://github.com/chubin/wttr.in#one-line-output
    # For more complex requests, we can also pass a custom async function
    # `response_callback`, that receives the response of the HTTP request and
    # you can manipulate it the way you want
    # await runner.register_block(
    #     http.PollingRequestBlock(
    #         "https://wttr.in/?format=%c+%t",
    #         format_error="",
    #         sleep=60 * 60,
    #     ),
    # )

    # You can use Pango markup for more control over text formating, as the
    # example below shows
    # For a description of how you can customize, look:
    # https://developer.gnome.org/pango/stable/pango-Markup.html
    await runner.register_block(
        datetime_block.DateTimeBlock(
            format_time=utils.pango_markup(" %H:%M", font_weight="bold"),
            format_date=utils.pango_markup(" %a %Y-%m-%d", font_weight="light"),
            default_state={"markup": types.MarkupText.PANGO},
        )
    )

    await runner.start()


if __name__ == "__main__":
    asyncio.run(main())
