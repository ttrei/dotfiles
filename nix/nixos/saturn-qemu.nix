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
    ./users/reinis.nix
  ];

  services.displayManager.autoLogin.enable = lib.mkForce false;

  networking.hostName = "saturn-qemu";

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

  # i3-volume-control expects pulseaudio
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
