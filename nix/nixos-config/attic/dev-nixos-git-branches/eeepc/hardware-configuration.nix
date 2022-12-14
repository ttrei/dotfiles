# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  boot.initrd.availableKernelModules = ["uhci_hcd" "ehci_pci" "ata_piix" "usb_storage" "sd_mod"];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/f0ed8c78-597b-4ab2-bcb7-4ce3029d399a";
    fsType = "ext4";
  };

  fileSystems."/media/Storage" = {
    device = "/dev/disk/by-uuid/2fa00274-ebdc-4e24-9978-2e49c4dd08f7";
    fsType = "ext4";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/cfe84c81-335b-4c0b-abaf-a17f187fb33e";}
  ];

  nix.maxJobs = lib.mkDefault 2;
}
