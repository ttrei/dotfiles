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
    ./hardware-configurations/qemu.nix
    ./packages/cli.nix
    ./packages/games.nix
    ./packages/gui.nix
    ./x11.nix
    ./packages/saturn.nix
    ./services/volume-control.nix
    ./users/reinis.nix
  ];

  networking.hostName = "saturn-qemu";

  services.displayManager.autoLogin.enable = lib.mkForce false;

  services.xserver.desktopManager.kodi = {
    enable = true;
    package = pkgs.kodi.withPackages (
      pkgs: with pkgs; [
        jellyfin
      ]
    );
  };

  virtualisation = {
    diskSize = 30 * 1024; # 10 GiB
    vmVariant.virtualisation = {
      writableStore = true;
      writableStoreUseTmpfs = false;
      forwardPorts = [
        {
          from = "host";
          host.port = 2255;
          guest.port = 22;
        }
        {
          from = "host";
          host.port = 8899;
          guest.port = 8899;
        }
      ];
    };
  };
  users.users.reinis = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5SV9eWOEcf37wKPqz0G/2kwtd7Xpi/JkkjP8sZR324+J7ItxIxlD7Q9KHBS5VgVQZm0sIm/mmJfUHs5L4bWxgXLDBOGOojm2jpq16FFG3GIFd+8w3oPZ7KX1ivczAzZsm/ehrKxkApTTaicD5iZppNErppZXhwvehpcuqlh5rMgHLU0uphnAR/3euc7GRa2es97mHSHukBMe1zxoa+sZF4aWnMDVeRFmi04xE5dr2235vnL++16ObRUXmTLKfK/JnnkHY9neRdq56WcG28swa2w60wo8Y5ebAyt3l9FVY1yn1FmgI4alDpXzkE/rNkqKY4Uim6tYoMooCAXtaNVmkkmOpuD7Y96oPV9qiVez61OazXW3tcwsV9OMI9FSr4smVo9TQsnzQXDWpoRPSqmLFoFDvEd7Mdl34EzmZs61Kt99CKgUEKk1UfN7DTdlbjKb+qMSM1zHLWqdHkM5z2GVgfuFAJjW+MUyjbvlL4eZlTr4+FcT2qMjpHJY82CCB4RE= reinis@home-desktop-nixos"
    ];
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    hostKeys = lib.mkForce [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    settings = {
      PasswordAuthentication = lib.mkForce true;
      PermitRootLogin = lib.mkForce "no";
    };
    extraConfig = lib.mkForce "";
  };

  # keys generated with
  # ssh-keygen -t ed25519 -N '' -C root@saturn-qemu -f ssh_host_ed25519_key
  environment.etc = {
    "ssh/ssh_host_ed25519_key" = {
      text = ''
        -----BEGIN OPENSSH PRIVATE KEY-----
        b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
        QyNTUxOQAAACCX++dTmhmS5gRvZccYhaDFxUN2mhzY74AuhwrUEA0kJwAAAJja7Dw72uw8
        OwAAAAtzc2gtZWQyNTUxOQAAACCX++dTmhmS5gRvZccYhaDFxUN2mhzY74AuhwrUEA0kJw
        AAAEB/AVSZ3C1iiJtody0fa0MOHqYMlfFAC0/ATfcJG3nKOZf751OaGZLmBG9lxxiFoMXF
        Q3aaHNjvgC6HCtQQDSQnAAAAEHJvb3RAc2F0dXJuLXFlbXUBAgMEBQ==
        -----END OPENSSH PRIVATE KEY-----
      '';
      mode = "0600";
    };
    "ssh/ssh_host_ed25519_key.pub" = {
      text = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJf751OaGZLmBG9lxxiFoMXFQ3aaHNjvgC6HCtQQDSQn root@saturn-qemu
      '';
      mode = "0644";
    };
  };

  networking.firewall.allowedTCPPorts = [
    4533 # navidrome
    8080 # kodi
    9091 # transmission UI
    56393 # transmission peer port
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

  services.saturnVolume = {
    enable = true;
    lanAddress = "127.0.0.1";
    # QEMU user networking forwards host connections from 10.0.2.2.
    lanSubnet = "10.0.2.0/24";
  };

  # saturn-volume and i3blocks use PulseAudio.
  services.pulseaudio.enable = true;
  services.pipewire.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
