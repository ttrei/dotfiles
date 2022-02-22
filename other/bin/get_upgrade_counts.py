#!/usr/bin/env python2

import json
import logging
import os
import socket

logging.basicConfig(
    filename="/var/tmp/upgrade_counts.json.log",
    level=logging.ERROR,
    format="%(asctime)s (%(levelname)s): %(message)s",
)


def main():
    summary = []
    entry = {"host": socket.gethostname()}
    if os.path.exists("/var/tmp/upgradable_packages.txt"):
        count = 0
        with open("/var/tmp/upgradable_packages.txt", "r") as f:
            lines = f.readlines()
        for line in lines:
            if line.startswith("Listing"):
                continue
            if line.startswith("building the system configuration"):
                continue
            if line.startswith("these derivations will be built"):
                continue
            if line.startswith("these paths will be fetched"):
                continue
            count += 1
        entry["count"] = str(count)
        summary.insert(0, entry)

    with open("/var/tmp/upgrade_counts.json.new", "w") as f:
        f.write(json.dumps(summary))
        os.rename("/var/tmp/upgrade_counts.json.new", "/var/tmp/upgrade_counts.json")


if __name__ == "__main__":
    main()
