#!/usr/bin/env python3

import iterfzf


import subprocess


def parse():
    maps = {
        "n": {},
        "i": {},
        "v": {},
    }
    for filename in ("nvim-imap.txt", "nvim-nmap.txt", "nvim-vmap.txt"):
        with open(filename, "r") as f:
            for line in f:
                if not line:
                    continue
                prefix = line[0]
                if prefix not in "niv":
                    continue
                lhs = line.split()[1]
                rhs = " ".join(line.split()[2:]).lstrip("*&@")
                maps[prefix][lhs] = rhs
    return maps


def select_mapping(mapping):
    keyvalues = []
    for key, value in mapping.items():
        keyvalues.append(f"{key}: {value}")
    # command = ["rofi", "-dmenu", "-i", "-p", "Select:", "-format", "i"]
    # command = ["fzf", "--prompt=Select: ", "--height=40%", "--border"]
    input_str = "\n".join(keyvalues)
    result = iterfzf.iterfzf(keyvalues)
    # get the index when using fzf: https://github.com/junegunn/fzf/issues/1660
    index = int(selected)
    return list(mapping.keys())[index]


def main():
    maps = parse()
    lhs = select_mapping(maps["n"])
    print(lhs, maps["n"][lhs])


if __name__ == "__main__":
    main()
