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
  boot.initrd.kernelModules = [ "mt7921u" ];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [ pkgs.mt7921-kernel-module ];

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

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/C1B9-00A8";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/e875bd93-8013-427c-a7b5-838d6811ba88";}
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.pulseaudio.enable = true;

  # To automatically switch USB WiFi receiver from CDROM mode to wifi mode
  hardware.usb-modeswitch.enable = true;

  environment.systemPackages = [
    pkgs.linux-firmware
  ];
}
