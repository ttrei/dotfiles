{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../hardware-configurations/qemu.nix
    ../packages/cli.nix
    ../packages/gui.nix
    ../users/reinis.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "nixos-qemu";
}
