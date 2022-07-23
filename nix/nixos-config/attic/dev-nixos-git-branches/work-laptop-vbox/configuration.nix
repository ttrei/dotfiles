# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./base.nix
    ./gui.nix
  ];

  nix.binaryCaches = [
    "http://192.168.122.35:80"
    "http://cache.nixos.org/" # fallback if our cache is down
  ];

  nixpkgs.overlays = [
    (import overlays/mypackages.nix)
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";

  networking.hostName = "reinis-nixos";
  networking.extraHosts = ''
    178.62.54.226  mazais
    192.168.1.205  reinis-pi
  '';

  time.timeZone = "Europe/Riga";

  nixpkgs.config = {
    allowUnfree = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.reinis = {
    isNormalUser = true;
    uid = 1000;
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.09";
}
