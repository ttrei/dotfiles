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

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
  };

  boot.loader.grub.extraEntries = ''
    menuentry "NixOS jupiter-work" {
      search --set=root --fs-uuid 20951e80-cc0a-4312-9654-3a43eb0156a0
      linux ($root)/nix/var/nix/profiles/system/kernel \
            init=($root)/nix/var/nix/profiles/system/init \
            systemConfig=($root)/nix/var/nix/profiles/system
      initrd ($root)/nix/var/nix/profiles/system/initrd
    }
  '';

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
    "/media/external-aija" = {
      device = "/dev/disk/by-uuid/F292D98392D94CAB";
      fsType = "ntfs";
      options = [
        "noauto"
        "nofail"
      ];
    };
    "/media/jupiter-work" = {
      device = "/dev/disk/by-uuid/20951e80-cc0a-4312-9654-3a43eb0156a0";
      fsType = "ext4";
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
