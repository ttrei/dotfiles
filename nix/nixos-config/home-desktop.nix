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
}
