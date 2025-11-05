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
    ./hardware-configurations/jupiter-work.nix
    ./packages/audio.nix
    ./packages/cli.nix
    ./packages/gui.nix
    ./wayland.nix
    ./users/reinis.nix
  ];

  networking.hostName = "jupiter-work";

  networking.extraHosts = ''
    127.0.0.1   mock.mcb mock.ips
  '';

  # Forward corporate ip ranges via wireguard to the OpenVPN tunnel on mercury.
  networking.wg-quick.interfaces.wg0 = {
    autostart = true;
    address = [ "192.168.50.1/32" ];
    privateKeyFile = "/root/wireguard-keys/mercury.key";
    dns = [ "10.57.6.3" ]; # Found with `resolvectl status` on mercury.
    peers = [
      {
        publicKey = "8BoqwfxDDRXROjpkdt595bV6urQw1VrltrvOAUuO2lA=";
        endpoint = "mercury:51820";
        persistentKeepalive = 25;
        # Find the ip ranges to forward (on mercury with OpenVPN up):
        # $ ip route show dev tun0
        # 10.57.3.0/24 via 192.168.226.1
        # 10.57.5.0/24 via 192.168.226.1
        # 10.57.6.0/24 via 192.168.226.1
        # 10.57.8.0/24 via 192.168.226.1
        # 10.57.9.0/24 via 192.168.226.1
        # 10.57.10.0/24 via 192.168.226.1
        # 10.57.11.0/24 via 192.168.226.1
        # 10.57.12.0/23 via 192.168.226.1
        # 10.57.14.0/24 via 192.168.226.1
        # 10.57.68.0/24 via 192.168.226.1
        # 10.57.200.0/24 via 192.168.226.1
        # 10.57.201.0/24 via 192.168.226.1
        # 10.57.206.0/24 via 192.168.226.1
        # 10.57.210.0/24 via 192.168.226.1
        # 10.99.0.0/16 via 192.168.226.1
        # 10.100.0.0/16 via 192.168.226.1
        # 172.27.5.0/24 via 192.168.226.1
        # 172.27.200.0/24 via 192.168.226.1
        # 192.168.226.0/24 proto kernel scope link src 192.168.226.45
        allowedIPs = [
          "10.57.3.0/24"
          "10.57.5.0/24"
          "10.57.6.0/24"
          "10.57.8.0/24"
          "10.57.9.0/24"
          "10.57.10.0/24"
          "10.57.11.0/24"
          "10.57.12.0/23"
          "10.57.14.0/24"
          "10.57.68.0/24"
          "10.57.200.0/24"
          "10.57.201.0/24"
          "10.57.206.0/24"
          "10.57.210.0/24"
          "10.99.0.0/16"
          "10.100.0.0/16"
          "172.27.5.0/24"
          "172.27.200.0/24"
          "192.168.226.0/24"
        ];
      }
    ];
  };

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      registry-mirrors = [ "http://docker.konts.lv:8080" ];
      insecure-registries = [
        "docker.konts.lv"
        "extregistry.konts.lv"
      ];
      debug = false;
      experimental = false;
      tls = false;
      dns = [ "10.57.6.3" ];
    };
  };

  services.pulseaudio.enable = false;

  # https://discourse.nixos.org/t/state-of-jackd-in-nixos/6007/14
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = true;
    pulse.enable = true;
  };

  services.redshift.enable = true;
  location = {
    provider = "manual";
    # Sigulda
    latitude = 57.15;
    longitude = 24.86;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
