#!/usr/bin/env python3

import json
import logging
import os
import pipes
import subprocess
from datetime import datetime, timezone

HOSTS = {
    "mazais": {"user": "reinis", "port": 22},
    "KODI": {"user": "user", "port": 22},
}

logging.basicConfig(
    filename="/var/tmp/remote-summary.json.log",
    format="%(asctime)s (%(levelname)s): %(message)s",
    level=logging.ERROR,
)


class RemoteOfflineError(Exception):
    pass


def read_remote_file(path, hostname):
    """Read remote file over ssh"""
    assert hostname in HOSTS
    user = HOSTS[hostname]["user"]
    port = HOSTS[hostname]["port"]
    login = f"{user}@{hostname}"
    quoted_path = pipes.quote(path)

    rc = subprocess.call(["ssh", "-p", str(port), login, f"test -f {quoted_path}"])
    if rc == 1:
        raise IOError(f"File {path} not found on {hostname}")
    elif rc == 255:
        raise RemoteOfflineError(f"{hostname} cannot be reached")
    elif rc != 0:
        raise Exception(f"Unexpected return code {rc}")

    command = f"stat --format '%Y' {quoted_path} && cat {quoted_path}"
    ssh = subprocess.Popen(
        ["ssh", "-p", str(port), login, command], stdout=subprocess.PIPE
    )
    data = [line.decode().rstrip("\n") for line in ssh.stdout]
    mtime = datetime.fromtimestamp(int(data[0]), tz=timezone.utc).isoformat(
        timespec="seconds"
    )
    lines = data[1:]
    return (mtime, lines)


def is_line_relevant(line):
    """Determine if a line from package manager output is relevant for us"""
    # dpkg
    if line.startswith("Listing"):
        return False
    # nixos-rebuild
    elif line.startswith("building the system configuration"):
        return False
    elif line.startswith("these derivations will be built"):
        return False
    elif line.startswith("these paths will be fetched"):
        return False
    else:
        return True


def summarize_upgrades(hostname: str):
    path = "/var/tmp/system_status/upgrades.txt"
    # apt list --upgradable
    #
    # Listing...
    # bind9-host/stable 1:9.11.5.P4+dfsg-5.1+deb10u1 amd64 [upgradable from: 1:9.11.5.P4+dfsg-5.1]
    # dnsutils/stable 1:9.11.5.P4+dfsg-5.1+deb10u1 amd64 [upgradable from: 1:9.11.5.P4+dfsg-5.1]
    mtime, lines = read_remote_file(path, hostname)
    logging.debug(f"    {path} mtime: {mtime}")
    lines = [l for l in lines if is_line_relevant(l)]
    for line in lines:
        logging.debug("    " + line.rstrip("\n"))
    return mtime, {"count": len(lines)}


def summarize_space(hostname: str):
    path = "/var/tmp/system_status/free_space.txt"
    # df -x tmpfs -x devtmpfs -x squashfs -B M --output=target,size,used,avail,pcent
    #
    # Mounted on     1M-blocks     Used    Avail Use%
    # /                 38725M   20603M   16133M  57%
    # /media/Storage  3754532M 2329650M 1424867M  63%
    mtime, lines = read_remote_file(path, hostname)
    logging.debug(f"    {path} mtime: {mtime}")
    lines = lines[1:]
    summary = {}
    for line in lines:
        fields = line.split()
        mountpoint = fields[0]
        summary[mountpoint] = {
            "size": int(fields[1].rstrip("M")),
            "used": int(fields[2].rstrip("M")),
            "available": int(fields[3].rstrip("M")),
            "percent": int(fields[4].rstrip("%")),
        }

    return mtime, summary


def summarize_memory(hostname: str):
    path = "/var/tmp/system_status/memory.txt"
    # free -m
    #               total        used        free      shared  buff/cache   available
    # Mem:          15898        1475       11601          33        2821       14067
    # Swap:             0           0           0
    mtime, lines = read_remote_file(path, hostname)
    logging.debug(f"    {path} mtime: {mtime}")
    assert len(lines) == 3
    _, total, _, _, _, _, available = lines[1].split()
    _, swap_total, _, swap_free = lines[2].split()
    summary = {
        "total": int(total),
        "available": int(available),
        "swap_total": int(swap_total),
        "swap_free": int(swap_free),
    }

    return mtime, summary


def summarize_load(hostname: str):
    #   /var/tmp/system_status/load_average.txt
    return 2000000000, 0.55


def main():
    new_summary = {}
    for hostname in HOSTS:
        try:
            entry = {
                "mtime": "1970-01-01T00:00:00+00:00",
            }
            logging.debug(f"Trying to read from {hostname}")
            mtime_upgrades, entry["upgrades"] = summarize_upgrades(hostname)
            mtime_space, entry["space"] = summarize_space(hostname)
            mtime_memory, entry["memory"] = summarize_memory(hostname)
            # mtime_load, entry['load'] = summarize_load(hostname)
            entry["mtime"] = min([mtime_upgrades, mtime_space, mtime_memory])
            new_summary[hostname] = entry
        except IOError as e:
            logging.error(e)
            new_summary[hostname] = {"error": str(e)}
        except RemoteOfflineError as e:
            logging.debug(e)
        except Exception as e:
            logging.error(f"Error while processing {hostname}: {e}")
            new_summary[hostname] = {"error": str(e)}

    summary_path = "/var/tmp/remote-summary.json"
    if os.path.exists(summary_path):
        with open(summary_path, "r") as f:
            summary = json.load(f)
            summary.update(new_summary)
    else:
        summary = new_summary

    tmpfile = "/var/tmp/remote-summary.json.new"
    with open(tmpfile, "w") as f:
        f.write(json.dumps(summary))
        os.rename(tmpfile, summary_path)


if __name__ == "__main__":
    main()
