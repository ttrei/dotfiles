{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configurations/htpc.nix
    ./packages/cli.nix
    ./packages/gui.nix
    ./packages/htpc.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "htpc-nixos";
}
