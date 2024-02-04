#!/usr/bin/env python3


def main():
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


if __name__ == "__main__":
    main()
