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

  boot.initrd.availableKernelModules = ["ahci" "ohci_pci" "ehci_pci" "xhci_pci" "firewire_ohci" "sd_mod"];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3c5b0708-454c-49ef-8e87-a5d86c6dcec9";
    fsType = "ext4";
  };

  fileSystems."/media/Storage" = {
    device = "/dev/disk/by-uuid/8e11d497-638e-48a6-ba17-97cc4bdc54b0";
    fsType = "ext4";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/9b2ec8e7-aff8-4237-9e74-6484eea14cbc";}
  ];

  nix.maxJobs = lib.mkDefault 12;
}
