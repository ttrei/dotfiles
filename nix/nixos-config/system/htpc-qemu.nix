{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configurations/qemu.nix
    ./packages/cli.nix
    ./packages/gui.nix
    ./packages/htpc.nix
    ./packages/games.nix
    ./users/user.nix
    ./users/reinis.nix
  ];

  services.transmission.enable = true;

# transmission daemon settings from kodi (Ubuntu)
# TODO: migrate to nixos options
# {
#     "alt-speed-down": 16000,
#     "alt-speed-enabled": false,
#     "alt-speed-time-begin": 540,
#     "alt-speed-time-day": 127,
#     "alt-speed-time-enabled": false,
#     "alt-speed-time-end": 1020,
#     "alt-speed-up": 5000,
#     "bind-address-ipv4": "0.0.0.0",
#     "bind-address-ipv6": "::",
#     "blocklist-enabled": false,
#     "blocklist-url": "http://www.example.com/blocklist",
#     "cache-size-mb": 4,
#     "dht-enabled": true,
#     "download-dir": "/media/Storage/torrents",
#     "download-queue-enabled": true,
#     "download-queue-size": 20,
#     "encryption": 0,
#     "idle-seeding-limit": 30,
#     "idle-seeding-limit-enabled": false,
#     "incomplete-dir": "/home/user/Downloads",
#     "incomplete-dir-enabled": false,
#     "lpd-enabled": true,
#     "message-level": 3,
#     "peer-congestion-algorithm": "",
#     "peer-id-ttl-hours": 6,
#     "peer-limit-global": 500,
#     "peer-limit-per-torrent": 50,
#     "peer-port": 60465,
#     "peer-port-random-high": 65535,
#     "peer-port-random-low": 49152,
#     "peer-port-random-on-start": false,
#     "peer-socket-tos": "default",
#     "pex-enabled": true,
#     "port-forwarding-enabled": true,
#     "preallocation": 1,
#     "prefetch-enabled": true,
#     "queue-stalled-enabled": true,
#     "queue-stalled-minutes": 30,
#     "ratio-limit": 3,
#     "ratio-limit-enabled": true,
#     "rename-partial-files": true,
#     "rpc-authentication-required": true,
#     "rpc-bind-address": "0.0.0.0",
#     "rpc-enabled": true,
#     "rpc-host-whitelist": "",
#     "rpc-host-whitelist-enabled": true,
#     "rpc-password": "{828146cc3a506cfd5b9beb8c8e3a4cb92b17813bT22fz9tj",
#     "rpc-port": 9091,
#     "rpc-url": "/transmission/",
#     "rpc-username": "user",
#     "rpc-whitelist": "192.168.*.* 127.0.0.1",
#     "rpc-whitelist-enabled": true,
#     "scrape-paused-torrents-enabled": true,
#     "script-torrent-done-enabled": false,
#     "script-torrent-done-filename": "",
#     "seed-queue-enabled": false,
#     "seed-queue-size": 10,
#     "speed-limit-down": 100,
#     "speed-limit-down-enabled": false,
#     "speed-limit-up": 100,
#     "speed-limit-up-enabled": false,
#     "start-added-torrents": true,
#     "trash-original-torrent-files": false,
#     "umask": 18,
#     "upload-slots-per-torrent": 14,
#     "utp-enabled": false
# }

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "htpc-nixos";
}
