{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configurations/desktop.nix
    ./packages/cli.nix
    ./packages/games.nix
    ./packages/gui.nix
    ./packages/qemu.nix
    ./users/reinis.nix
  ];

  networking.hostName = "home-desktop-nixos";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
