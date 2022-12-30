{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configurations/qemu.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "nixos-qemu";
}
