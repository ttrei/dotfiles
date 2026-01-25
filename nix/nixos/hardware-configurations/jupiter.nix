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

  # os-prober detected jupiter-work but didn't write it to grub for some reason.
  # The following entry is copy-pasted and adjusted from the main nixos entry in /boot/grub/grub.cfg.
  boot.loader.grub.extraEntries = ''
    menuentry "NixOS jupiter-work" {
    search --set=drive1 --fs-uuid c2be14ff-91b7-41b3-9d1a-d0b5b743aa0e
    search --set=drive2 --fs-uuid c2be14ff-91b7-41b3-9d1a-d0b5b743aa0e
      linux ($drive2)/nix/var/nix/profiles/system/kernel init=/nix/var/nix/profiles/system/init loglevel=4 lsm=landlock,yama,bpf
      initrd ($drive2)/nix/var/nix/profiles/system/initrd
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
      device = "/dev/disk/by-uuid/c2be14ff-91b7-41b3-9d1a-d0b5b743aa0e";
      fsType = "ext4";
      options = [
        "noauto"
        "nofail"
      ];
    };

    # NFS
    # "/mnt/pluto/movies" = {
    #   device = "pluto:/movies";
    #   fsType = "nfs";
    #   options = [
    #     "x-systemd.automount"
    #     "x-systemd.idle-timeout=600"
    #     "noauto"
    #     "nofail"
    #   ];
    # };
    "/mnt/pluto/music" = {
      device = "pluto:/music";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "noauto"
        "nofail"
      ];
    };
    "/mnt/pluto/music-from-saturn" = {
      device = "pluto:/music-from-saturn";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "noauto"
        "nofail"
      ];
    };
    "/mnt/pluto/torrents-complete" = {
      device = "pluto:/torrents-complete";
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

  hardware.opengl.enable = true;

  hardware.bluetooth.enable = true;
}
