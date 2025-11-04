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

  networking.wireguard.interfaces.wg0 = {
    ips = [ "192.168.50.1/32" ];
    listenPort = 51820;
    privateKeyFile = "/root/wireguard-keys/mercury.key";
    peers = [
      {
        # jupiter-work publickey: q5H5OzrAQ7K6AI+mu88JRKffMvyqYLFF4UCHm0ObCQY=
        publicKey = "TODO";
        allowedIPs = [ "192.168.50.2/32" ];
        endpoint = "mercury:51820";
        persistentKeepalive = 25;
      }
    ];
  };

  virtualisation.docker.enable = true;

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
