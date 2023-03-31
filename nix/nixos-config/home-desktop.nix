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

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "home-desktop-nixos";
}
