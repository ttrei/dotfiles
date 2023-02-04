{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configurations/desktop.nix
    ./packages/cli.nix
    ./packages/gui.nix
  ];

  # boot.loader.grub.enable = true;
  # boot.loader.grub.version = 2;
  # # boot.loader.grub.device = "/dev/sda";
  # boot.loader.grub.device = "nodev";
  # # boot.loader.grub.useOSProber = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "home-desktop-nixos";
}
