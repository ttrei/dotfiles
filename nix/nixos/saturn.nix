{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
    ./hardware-configurations/saturn.nix
    ./packages/cli.nix
    ./packages/games.nix
    ./packages/gui.nix
    ./x11.nix
    ./packages/saturn.nix
    ./users/reinis.nix
  ];

  networking.hostName = "saturn";

  networking.wg-quick.interfaces = {
    # Mullvad device "robust tiger"
    wg-mullvad = {
      # Generate config here:
      # https://mullvad.net/en/account/wireguard-config
      # Put the private key in a file at the privateKeyFile path.
      # Put the "wireguard key" in publicKey.
      autostart = true;
      address = [ "10.73.249.174/32" ];
      dns = [ "10.64.0.1" ];
      privateKeyFile = "/root/wireguard-keys/mullvad/wg-mullvad.key";
      peers = [
        {
          publicKey = "94qIvXgF0OXZ4IcquoS7AO57OV6JswUFgdONgGiq+jo=";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "185.65.135.69:51820";
        }
      ];
    };
  };

  services.xserver.desktopManager.kodi = {
    enable = true;
    package = pkgs.kodi.withPackages (
      pkgs: with pkgs; [
        inputstream-adaptive
        inputstream-ffmpegdirect
        inputstreamhelper
        inputstream-rtmp
        trakt
        youtube
      ]
    );
  };

  services.transmission.enable = true;
  services.transmission.package = pkgs.transmission_4;
  services.transmission.settings = {
    # https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md
    dht-enabled = true;
    download-queue-enabled = true;
    download-queue-size = 20;
    download-dir = "/media/Storage/torrents";
    incomplete-dir = "/media/Storage/torrents/.incomplete";
    incomplete-dir-enabled = true;
    encryption = 0;
    peer-limit-global = 500;
    peer-limit-per-torrent = 50;
    peer-port = 56322;
    pex-enabled = true;
    port-forwarding-enabled = true;
    preallocation = 1;
    prefetch-enabled = true;
    ratio-limit = 3;
    ratio-limit-enabled = true;
    rename-partial-files = true;
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

  # services.navidrome = {
  #   enable = true;
  #   settings = {
  #     # https://www.navidrome.org/docs/usage/configuration-options/
  #     Address = "0.0.0.0";
  #     Port = 4533;
  #     MusicFolder = "/media/Storage/music";
  #   };
  # };

  networking.firewall.allowedTCPPorts = [
    4533 # navidrome
    8080 # kodi
    9091 # transmission UI
    56322 # transmission peer port
  ];

  security.sudo.extraRules = [
    {
      users = [ "reinis" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl start wg-quick-wg-mullvad.service";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl stop wg-quick-wg-mullvad.service";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl start transmission.service";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl stop transmission.service";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
      ];
    }
  ];

  services.samba = {
    # NOTE: Need to set up SAMBA username/password with
    #       sudo smbpasswd -a reinis
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        security = "user";
        workgroup = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        #use sendfile = yes
        #max protocol = smb2
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = [
          "192.168.8."
          "127.0.0.1"
          "localhost"
        ];
        "hosts deny" = [ "0.0.0.0/0" ];
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      tvshows = {
        path = "/media/Storage/tvshows";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "reinis";
        "force group" = "users";
      };
      tvshows2 = {
        path = "/media/Lielais/tvshows";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "reinis";
        "force group" = "users";
      };
      movies = {
        path = "/media/Lielais/movies";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "reinis";
        "force group" = "users";
      };
      movies2 = {
        path = "/media/Lielais/movies-radarr";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "reinis";
        "force group" = "users";
      };
    };
  };
  networking.firewall.allowPing = true;

  # i3-volume-control expects pulseaudio
  services.pulseaudio.enable = true;
  services.pipewire.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
