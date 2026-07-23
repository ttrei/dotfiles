#!/usr/bin/env python3
from __future__ import annotations

import argparse
import errno
import json
import os
import re
import subprocess
import sys
import threading
import time
from collections.abc import Callable
from dataclasses import dataclass
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse

VOLUME_RE = re.compile(r"(\d+)%")
MUTE_RE = re.compile(r"\b(yes|no)\b", re.IGNORECASE)
VOLUME_LOCK = threading.Lock()
OSD_MIN_INTERVAL_SECONDS = 0.12
OSD_LAST_WRITE = 0.0


@dataclass(frozen=True)
class ServerConfig:
    host: str
    port: int
    step: int
    sink: str
    index: Path
    fallback_base_url: str
    preset_low: int
    preset_mid: int
    preset_high: int
    osd_fifo: Path | None
    refresh_i3blocks: bool


@dataclass(frozen=True)
class VolumeState:
    volume: int
    muted: bool

    def as_dict(self) -> dict[str, int | bool]:
        return {"volume": self.volume, "muted": self.muted}


class BadRequestError(ValueError):
    pass


class PactlError(RuntimeError):
    pass


class VolumeHTTPServer(ThreadingHTTPServer):
    allow_reuse_address = True
    daemon_threads = True

    def __init__(
        self,
        server_address: tuple[str, int],
        handler_class: type[BaseHTTPRequestHandler],
        config: ServerConfig,
    ):
        super().__init__(server_address, handler_class)
        self.config = config


class VolumeRequestHandler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    server_version = "SaturnVolume/1.0"

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        config = self.server.config

        try:
            if parsed.path == "/":
                self._send_bytes(
                    HTTPStatus.OK,
                    render_index(config).encode(),
                    "text/html; charset=utf-8",
                )
            elif parsed.path == "/volume":
                self._send_json(HTTPStatus.OK, read_state(config).as_dict())
            elif parsed.path == "/manifest.json":
                self._send_json(
                    HTTPStatus.OK,
                    {
                        "name": "Saturn Volume",
                        "short_name": "Volume",
                        "start_url": "/",
                        "display": "standalone",
                        "background_color": "#111318",
                        "theme_color": "#111318",
                    },
                    content_type="application/manifest+json; charset=utf-8",
                )
            else:
                self._send_json(HTTPStatus.NOT_FOUND, {"error": "not found"})
        except PactlError as exc:
            self._handle_pactl_error(exc)

    def do_POST(self) -> None:
        parsed = urlparse(self.path)
        config = self.server.config
        self._discard_request_body()

        try:
            if parsed.path == "/volume/set":
                volume = parse_volume_query(parsed.query)
                streaming = parse_qs(parsed.query).get("stream") == ["1"]
                state = mutate_and_read(
                    config,
                    lambda: set_volume(config, volume),
                    throttle_osd=streaming,
                )
            elif parsed.path == "/volume/up":
                state = mutate_and_read(config, lambda: change_volume(config, config.step))
            elif parsed.path == "/volume/down":
                state = mutate_and_read(config, lambda: change_volume(config, -config.step))
            elif parsed.path == "/volume/mute":
                state = mutate_and_read(config, lambda: toggle_mute(config))
            else:
                self._send_json(HTTPStatus.NOT_FOUND, {"error": "not found"})
                return
        except BadRequestError as exc:
            self._send_json(HTTPStatus.BAD_REQUEST, {"error": str(exc)})
            return
        except PactlError as exc:
            self._handle_pactl_error(exc)
            return

        self._send_json(HTTPStatus.OK, state.as_dict())

    def do_OPTIONS(self) -> None:
        self._send_bytes(HTTPStatus.NO_CONTENT, b"", "text/plain; charset=utf-8")

    def log_message(self, fmt: str, *args: object) -> None:
        print(f"{self.address_string()} - {fmt % args}", file=sys.stderr)

    def _send_json(
        self,
        status: HTTPStatus,
        body: dict[str, object],
        *,
        content_type: str = "application/json; charset=utf-8",
    ) -> None:
        self._send_bytes(status, json.dumps(body, separators=(",", ":")).encode(), content_type)

    def _send_bytes(self, status: HTTPStatus, body: bytes, content_type: str) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()
        if self.command != "HEAD" and body:
            self.wfile.write(body)

    def _discard_request_body(self) -> None:
        length = int(self.headers.get("Content-Length", "0") or "0")
        if length > 0:
            self.rfile.read(length)

    def _handle_pactl_error(self, exc: PactlError) -> None:
        print(f"pactl error while handling {self.path}: {exc}", file=sys.stderr)
        self._send_json(HTTPStatus.INTERNAL_SERVER_ERROR, {"error": "pactl failed"})


def run_command(args: list[str]) -> str:
    try:
        result = subprocess.run(args, check=True, capture_output=True, text=True, timeout=3)
    except subprocess.CalledProcessError as exc:
        stderr = exc.stderr.strip() if exc.stderr else ""
        stdout = exc.stdout.strip() if exc.stdout else ""
        detail = stderr or stdout or f"exit status {exc.returncode}"
        raise PactlError(f"{' '.join(args)}: {detail}") from exc
    except subprocess.TimeoutExpired as exc:
        raise PactlError(f"{' '.join(args)}: timed out") from exc

    return result.stdout


def pactl(config: ServerConfig, *args: str) -> str:
    return run_command(["pactl", *args])


def read_volume(config: ServerConfig) -> int:
    output = pactl(config, "get-sink-volume", config.sink)
    match = VOLUME_RE.search(output)
    if match is None:
        raise PactlError(f"could not parse volume from pactl output: {output.strip()}")
    return int(match.group(1))


def read_muted(config: ServerConfig) -> bool:
    output = pactl(config, "get-sink-mute", config.sink)
    match = MUTE_RE.search(output)
    if match is None:
        raise PactlError(f"could not parse mute state from pactl output: {output.strip()}")
    return match.group(1).lower() == "yes"


def read_state(config: ServerConfig) -> VolumeState:
    return VolumeState(volume=read_volume(config), muted=read_muted(config))


def clamp_volume(volume: int) -> int:
    return max(0, min(100, volume))


def set_volume(config: ServerConfig, volume: int) -> None:
    pactl(config, "set-sink-volume", config.sink, f"{clamp_volume(volume)}%")


def change_volume(config: ServerConfig, delta: int) -> None:
    set_volume(config, read_volume(config) + delta)


def toggle_mute(config: ServerConfig) -> None:
    pactl(config, "set-sink-mute", config.sink, "toggle")


def mutate_and_read(
    config: ServerConfig,
    mutate: Callable[[], None],
    *,
    throttle_osd: bool = False,
) -> VolumeState:
    with VOLUME_LOCK:
        mutate()
        state = read_state(config)
        trigger_osd(config, state.volume, throttle=throttle_osd)
        refresh_i3blocks(config)
        return state


def trigger_osd(config: ServerConfig, volume: int, *, throttle: bool = False) -> None:
    global OSD_LAST_WRITE

    if config.osd_fifo is None:
        return

    now = time.monotonic()
    if throttle and now - OSD_LAST_WRITE < OSD_MIN_INTERVAL_SECONDS:
        return

    try:
        fd = os.open(config.osd_fifo, os.O_WRONLY | os.O_NONBLOCK)
    except OSError as exc:
        if exc.errno not in {errno.ENOENT, errno.ENXIO}:
            print(f"could not open OSD FIFO {config.osd_fifo}: {exc}", file=sys.stderr)
        return

    try:
        with os.fdopen(fd, "w", encoding="utf-8") as fifo:
            fifo.write(f"{clamp_volume(volume)}\n")
        OSD_LAST_WRITE = now
    except OSError as exc:
        print(f"could not write OSD FIFO {config.osd_fifo}: {exc}", file=sys.stderr)


def refresh_i3blocks(config: ServerConfig) -> None:
    if not config.refresh_i3blocks:
        return
    subprocess.run(
        ["pkill", "-RTMIN+10", "i3blocks"],
        check=False,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def parse_volume_query(query: str) -> int:
    values = parse_qs(query).get("v")
    if not values or values[0].strip() == "":
        raise BadRequestError("missing v query parameter")

    try:
        return int(values[0])
    except ValueError as exc:
        raise BadRequestError("v must be an integer percentage") from exc


def render_index(config: ServerConfig) -> str:
    replacements = {
        "__SATURN_VOLUME_FALLBACK_BASE_URL__": json.dumps(config.fallback_base_url),
        "__SATURN_VOLUME_STEP__": str(config.step),
        "__SATURN_VOLUME_PRESET_LOW__": str(config.preset_low),
        "__SATURN_VOLUME_PRESET_MID__": str(config.preset_mid),
        "__SATURN_VOLUME_PRESET_HIGH__": str(config.preset_high),
    }
    html = config.index.read_text(encoding="utf-8")
    for placeholder, value in replacements.items():
        html = html.replace(placeholder, value)
    return html


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="HTTP volume control service for saturn")
    parser.add_argument("--host", default="0.0.0.0")
    parser.add_argument("--port", type=int, default=8899)
    parser.add_argument("--step", type=int, default=1)
    parser.add_argument("--sink", default="@DEFAULT_SINK@")
    parser.add_argument("--index", type=Path, required=True)
    parser.add_argument("--fallback-base-url", default="http://192.168.8.205:8899")
    parser.add_argument("--preset-low", type=int, default=25)
    parser.add_argument("--preset-mid", type=int, default=50)
    parser.add_argument("--preset-high", type=int, default=75)
    parser.add_argument("--osd-fifo", type=Path)
    parser.add_argument("--no-refresh-i3blocks", dest="refresh_i3blocks", action="store_false")
    parser.set_defaults(refresh_i3blocks=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    config = ServerConfig(
        host=args.host,
        port=args.port,
        step=args.step,
        sink=args.sink,
        index=args.index,
        fallback_base_url=args.fallback_base_url,
        preset_low=args.preset_low,
        preset_mid=args.preset_mid,
        preset_high=args.preset_high,
        osd_fifo=args.osd_fifo,
        refresh_i3blocks=args.refresh_i3blocks,
    )

    server = VolumeHTTPServer((config.host, config.port), VolumeRequestHandler, config)
    print(f"serving saturn volume control on http://{config.host}:{config.port}", file=sys.stderr)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
