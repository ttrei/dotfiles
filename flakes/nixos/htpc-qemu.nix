{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
    ./hardware-configurations/qemu.nix
    ./packages/cli.nix
    ./packages/games.nix
    ./packages/gui.nix
    ./packages/htpc.nix
    ./users/reinis.nix
  ];

  services.xserver.displayManager.autoLogin.enable = lib.mkForce false;

  networking.hostName = "htpc-qemu";

  networking.wg-quick.interfaces = {
    wg-mullvad = {
      autostart = true;
      address = ["10.66.33.143/32"];
      dns = ["10.64.0.1"];
      privateKeyFile = "/root/wireguard-keys/mullvad/wg-mullvad.key";
      peers = [
        {
          publicKey = "XscA5gebj51nmhAr6o+aUCnMHWGjbS1Gvvd0tuLRiFE=";
          allowedIPs = ["0.0.0.0/0"];
          # se23-wireguard
          endpoint = "45.83.220.70:51820";
        }
      ];
    };
  };

  services.transmission.enable = true;
  services.transmission.settings = {
    dht-enabled = true;
    download-queue-enabled = true;
    download-queue-size = 20;
    encryption = 0;
    peer-limit-global = 500;
    peer-limit-per-torrent = 50;
    peer-port = 56393;
    pex-enabled = true;
    port-forwarding-enabled = true;
    preallocation = 1;
    prefetch-enabled = true;
    ratio-limit = 3;
    ratio-limit-enabled = true;
    rpc-authentication-required = true;
    rpc-bind-address = "0.0.0.0";
    rpc-enabled = true;
    rpc-host-whitelist = "";
    rpc-host-whitelist-enabled = true;
    rpc-password = "{828146cc3a506cfd5b9beb8c8e3a4cb92b17813bT22fz9tj";
    rpc-port = 9091;
    rpc-url = "/transmission/";
    rpc-username = "user";
    rpc-whitelist = "192.168.*.* 127.0.0.1";
    rpc-whitelist-enabled = true;
  };

  services.sonarr = {
    enable = true;
    group = "users";
    user = "reinis";
    dataDir = "/home/reinis/.local/share/Sonarr";
    openFirewall = true; # port: 8989
  };

  services.radarr = {
    enable = true;
    group = "users";
    user = "reinis";
    dataDir = "/home/reinis/.local/share/Radarr";
    openFirewall = true; # port: 7878
  };

  services.jackett = {
    enable = true;
    group = "users";
    user = "reinis";
    dataDir = "/home/reinis/.local/share/Jackett";
    openFirewall = true; # port: 9117
  };

  services.bazarr = {
    enable = true;
    group = "users";
    user = "reinis";
    openFirewall = true;
    listenPort = 6767;
  };

  services.navidrome = {
    enable = true;
    settings = {
      # https://www.navidrome.org/docs/usage/configuration-options/
      Address = "127.0.0.1";
      Port = 4533;
      MusicFolder = "/home/reinis/music";
    };
  };

  networking.firewall.allowedTCPPorts = [
    4533 # navidrome
    8080 # kodi
    9091 # transmission UI
    56393 # transmission peer port
  ];

  security.sudo.extraRules = [
    {
      users = ["reinis"];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl start wg-quick-wg-mullvad.service";
          options = ["SETENV" "NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/systemctl stop wg-quick-wg-mullvad.service";
          options = ["SETENV" "NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/systemctl start transmission.service";
          options = ["SETENV" "NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/systemctl stop transmission.service";
          options = ["SETENV" "NOPASSWD"];
        }
      ];
    }
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
