# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e4462353-9c08-4a8f-8045-08914128972b";
    fsType = "ext4";
  };

  fileSystems."/media/Lielais" = {
    device = "/dev/disk/by-uuid/779a0988-5573-4161-9b41-f963f9a96f2d";
  };

  fileSystems."/media/Storage" = {
    device = "/dev/disk/by-uuid/4784089f-fdf3-4777-8822-d3b3c5a25c76";
  };

  fileSystems."/media/kodi-ubuntu" = {
    device = "/dev/disk/by-uuid/9ef0e4e4-b28f-44b5-9686-b681255ce62e";
    options = ["noauto"];
  };

  fileSystems."/media/kodi-ubuntu-old" = {
    device = "/dev/disk/by-uuid/9a16a58c-376f-4e22-b9eb-7944063f69dd";
    options = ["noauto"];
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/C1B9-00A8";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/e875bd93-8013-427c-a7b5-838d6811ba88";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
