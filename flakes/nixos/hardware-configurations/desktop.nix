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

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/77e6b686-47f7-4a6c-ae1b-a2131c4adcbd";
    fsType = "ext4";
  };

  fileSystems."/media/storage-new" = {
    device = "/dev/disk/by-uuid/c7b00111-51f7-4c09-bf16-4239d25e72e1";
  };

  fileSystems."/media/extra-storage" = {
    device = "/dev/disk/by-uuid/52945d79-d15b-4c45-b939-dd8b52b9a728";
  };

  fileSystems."/media/debian-work" = {
    device = "/dev/disk/by-uuid/3d855ec1-722c-48a1-b273-cd934d321527";
    options = ["noauto"];
  };

  fileSystems."/media/linux-main" = {
    device = "/dev/disk/by-uuid/56b3dbfe-a167-4d92-a4e3-826ba53c2a47";
    options = ["noauto"];
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/1027-5389";
    fsType = "vfat";
  };

  swapDevices = [];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
