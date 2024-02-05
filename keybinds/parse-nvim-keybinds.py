#!/usr/bin/env python3


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
    command = ["rofi", "-dmenu", "-i", "-p", "Select:", "-format", "i"]
    rofi_process = subprocess.Popen(
        command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
    )
    selected, error = rofi_process.communicate("\n".join(keyvalues))
    if rofi_process.returncode != 0:
        print(f"Rofi error: {error}")
        return None
    index = int(selected)
    return list(mapping.keys())[index]


def main():
    maps = parse()
    lhs = select_mapping(maps["n"])
    print(lhs, maps["n"][lhs])


if __name__ == "__main__":
    main()
