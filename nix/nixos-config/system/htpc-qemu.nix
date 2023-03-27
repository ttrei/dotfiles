{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configurations/qemu.nix
    ./packages/cli.nix
    ./packages/gui.nix
    ./packages/htpc.nix
    ./packages/games.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "htpc-nixos";
}
