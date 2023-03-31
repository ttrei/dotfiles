{
  config,
  pkgs,
  ...
}: let
  unstable = import <nixos-unstable> {
    # https://github.com/NixOS/nixpkgs/issues/55366
    # Include the nixos config when importing nixos-unstable
    # But remove packageOverrides to avoid infinite recursion
    config = removeAttrs config.nixpkgs.config [ "packageOverrides" ];
  };
in {

  # https://github.com/NixOS/nixpkgs/issues/55366
  # https://nixos.org/manual/nixos/unstable/#sec-replace-modules
  disabledModules = [ "services/audio/navidrome.nix" ];

  imports = [
    ./hardware-configurations/qemu.nix
    ./packages/cli.nix
    ./packages/gui.nix
    ./packages/htpc.nix
    ./packages/games.nix
    ./users/reinis.nix

    # https://github.com/NixOS/nixpkgs/issues/55366
    # https://nixos.org/manual/nixos/unstable/#sec-replace-modules
    <nixos-unstable/nixos/modules/services/audio/navidrome.nix>
  ];

  # https://github.com/NixOS/nixpkgs/issues/55366
  # Override select packages to use the unstable channel
  nixpkgs.config.packageOverrides = pkgs: {
    navidrome = unstable.navidrome;
  };

  networking.hostName = "kodi-qemu";

  networking.wg-quick.interfaces = {
    wg-mullvad = {
      autostart = false;
      address = [ "10.64.155.123/32" ];
      dns = [ "10.64.0.1" ];
      privateKeyFile = "/root/wireguard-keys/mullvad/wg-mullvad.key";
      peers = [
        {
          publicKey = "m4jnogFbACz7LByjo++8z5+1WV0BuR1T7E1OWA+n8h0=";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "193.138.218.130:51820";
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
    peer-port = 60465;
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

}
