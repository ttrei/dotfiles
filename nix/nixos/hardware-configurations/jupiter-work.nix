{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-amd"
    "snd-seq"
    "snd-rawmidi"
  ];
  boot.extraModulePackages = [ ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub.enable = false;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/c2be14ff-91b7-41b3-9d1a-d0b5b743aa0e";
      fsType = "ext4";
    };
    "/media/jupiter" = {
      device = "/dev/disk/by-uuid/77e6b686-47f7-4a6c-ae1b-a2131c4adcbd";
      fsType = "ext4";
      options = [
        "noauto"
        "nofail"
      ];
    };
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.bluetooth.enable = true;

  services.udev.extraRules = ''
    # Disable USB autosuspend for Moergo Glove80
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="16c0", ATTR{idProduct}=="27db", ATTR{power/autosuspend}="-1"
  '';

}
