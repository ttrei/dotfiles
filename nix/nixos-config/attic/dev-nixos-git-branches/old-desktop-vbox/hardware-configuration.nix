# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [];

  boot.initrd.availableKernelModules = ["ata_piix" "ohci_pci" "sd_mod" "sr_mod"];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2da9d914-0073-444c-9334-2e975018e7eb";
    fsType = "ext4";
  };

  fileSystems."/media/Storage" = {
    device = "/dev/disk/by-uuid/8e11d497-638e-48a6-ba17-97cc4bdc54b0";
    fsType = "ext4";
  };

  swapDevices = [];

  nix.maxJobs = lib.mkDefault 3;
  virtualisation.virtualbox.guest.enable = true;
}
