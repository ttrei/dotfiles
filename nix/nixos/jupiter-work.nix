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

  # Printing (Brother HL-L2340DW)
  # http://localhost:631/admin -> Find New Printers -> Add This Printer -> Continue -> Make = Generic -> Continue ->
  # Model = IPP Everywhere -> Add Printer
  # 2024-09-26: Disabled to avoid https://www.evilsocket.net/2024/09/26/Attacking-UNIX-systems-via-CUPS-Part-I/
  # services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
