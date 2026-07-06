#!/usr/bin/env python3
from __future__ import annotations

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

HOST = "0.0.0.0"
PORT = 8899
STEP = 1
SINK = "@DEFAULT_SINK@"
OSD_FIFO = Path("/run/user/1000/xob.fifo")
OSD_MIN_INTERVAL_SECONDS = 0.12
INDEX_HTML = Path(__file__).with_name("index.html").read_bytes()

VOLUME_RE = re.compile(r"(\d+)%")
MUTE_RE = re.compile(r"\b(yes|no)\b", re.IGNORECASE)
VOLUME_LOCK = threading.Lock()
OSD_LAST_WRITE = 0.0


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


class VolumeRequestHandler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    server_version = "SaturnVolume/1.0"

    def do_GET(self) -> None:
        path = urlparse(self.path).path

        try:
            if path == "/":
                self._send_bytes(HTTPStatus.OK, INDEX_HTML, "text/html; charset=utf-8")
            elif path == "/volume":
                self._send_json(HTTPStatus.OK, read_state().as_dict())
            elif path == "/manifest.json":
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
        self._discard_request_body()

        try:
            if parsed.path == "/volume/set":
                volume = parse_volume_query(parsed.query)
                streaming = parse_qs(parsed.query).get("stream") == ["1"]
                state = mutate_and_read(
                    lambda: set_volume(volume),
                    throttle_osd=streaming,
                )
            elif parsed.path == "/volume/up":
                state = mutate_and_read(lambda: change_volume(STEP))
            elif parsed.path == "/volume/down":
                state = mutate_and_read(lambda: change_volume(-STEP))
            elif parsed.path == "/volume/mute":
                state = mutate_and_read(toggle_mute)
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
        if body:
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


def pactl(*args: str) -> str:
    return run_command(["pactl", *args])


def read_volume() -> int:
    output = pactl("get-sink-volume", SINK)
    match = VOLUME_RE.search(output)
    if match is None:
        raise PactlError(f"could not parse volume from pactl output: {output.strip()}")
    return int(match.group(1))


def read_muted() -> bool:
    output = pactl("get-sink-mute", SINK)
    match = MUTE_RE.search(output)
    if match is None:
        raise PactlError(f"could not parse mute state from pactl output: {output.strip()}")
    return match.group(1).lower() == "yes"


def read_state() -> VolumeState:
    return VolumeState(volume=read_volume(), muted=read_muted())


def clamp_volume(volume: int) -> int:
    return max(0, min(100, volume))


def set_volume(volume: int) -> None:
    pactl("set-sink-volume", SINK, f"{clamp_volume(volume)}%")


def change_volume(delta: int) -> None:
    set_volume(read_volume() + delta)


def toggle_mute() -> None:
    pactl("set-sink-mute", SINK, "toggle")


def mutate_and_read(
    mutate: Callable[[], None],
    *,
    throttle_osd: bool = False,
) -> VolumeState:
    with VOLUME_LOCK:
        mutate()
        state = read_state()
        trigger_osd(state.volume, throttle=throttle_osd)
        refresh_i3blocks()
        return state


def trigger_osd(volume: int, *, throttle: bool = False) -> None:
    global OSD_LAST_WRITE

    now = time.monotonic()
    if throttle and now - OSD_LAST_WRITE < OSD_MIN_INTERVAL_SECONDS:
        return

    try:
        fd = os.open(OSD_FIFO, os.O_WRONLY | os.O_NONBLOCK)
    except OSError as exc:
        if exc.errno not in {errno.ENOENT, errno.ENXIO}:
            print(f"could not open OSD FIFO {OSD_FIFO}: {exc}", file=sys.stderr)
        return

    try:
        with os.fdopen(fd, "w", encoding="utf-8") as fifo:
            fifo.write(f"{clamp_volume(volume)}\n")
        OSD_LAST_WRITE = now
    except OSError as exc:
        print(f"could not write OSD FIFO {OSD_FIFO}: {exc}", file=sys.stderr)


def refresh_i3blocks() -> None:
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


def main() -> None:
    server = ThreadingHTTPServer((HOST, PORT), VolumeRequestHandler)
    server.daemon_threads = True
    print(f"serving saturn volume control on http://{HOST}:{PORT}", file=sys.stderr)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
