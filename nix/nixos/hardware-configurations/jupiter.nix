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
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;

  boot.supportedFilesystems = [ "nfs" ];

  fileSystems = {
    "/boot/efi" = {
      device = "/dev/disk/by-uuid/6EB0-DFE9";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-uuid/77e6b686-47f7-4a6c-ae1b-a2131c4adcbd";
      fsType = "ext4";
    };
    "/media/storage-new" = {
      device = "/dev/disk/by-uuid/c7b00111-51f7-4c09-bf16-4239d25e72e1";
      fsType = "ext4";
      options = [ "nofail" ];
    };
    "/media/external-madara" = {
      device = "/dev/disk/by-uuid/D2B0FEEBB0FED547";
      fsType = "ntfs";
      options = [
        "noauto"
        "nofail"
      ];
    };
    "/media/external-aija" = {
      device = "/dev/disk/by-uuid/F292D98392D94CAB";
      fsType = "ntfs";
      options = [
        "noauto"
        "nofail"
      ];
    };
    "/media/debian-work" = {
      device = "/dev/disk/by-uuid/3d855ec1-722c-48a1-b273-cd934d321527";
      options = [
        "noauto"
        "nofail"
      ];
    };
    "/media/linux-main" = {
      device = "/dev/disk/by-uuid/56b3dbfe-a167-4d92-a4e3-826ba53c2a47";
      options = [
        "noauto"
        "nofail"
      ];
    };

    # NFS
    "/mnt/movies" = {
      device = "pluto:/movies";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
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
}
