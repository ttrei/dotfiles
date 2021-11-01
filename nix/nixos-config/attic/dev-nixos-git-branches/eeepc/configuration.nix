# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./base.nix
    ./gui.nix
  ];

  nix.binaryCaches = [
    "http://192.168.122.35:80"
    "http://cache.nixos.org/" # fallback if our cache is down
  ];

  nixpkgs.overlays = [
    (import overlays/mypackages.nix)
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  #boot.kernelParams = [ "nomodeset" ];

  boot.loader.grub.extraEntries = "
    menuentry 'Windows XP' --class windows --class os $menuentry_id_option 'osprober-chain-B23C567A3C563A15' {
        insmod part_msdos
        insmod ntfs
        set root='hd0,msdos1'
        if [ x$feature_platform_search_hint = xy ]; then
          search --no-floppy --fs-uuid --set=root --hint-bios=hd0,msdos1 --hint-efi=hd0,msdos1 --hint-baremetal=ahci0,msdos1  B23C567A3C563A15
        else
          search --no-floppy --fs-uuid --set=root B23C567A3C563A15
        fi
        parttool \${root} hidden-
        drivemap -s (hd0) \${root}
        chainloader +1
    }
  ";

  networking.hostName = "eeepc-nixos";
  networking.wireless.enable = true;
  networking.extraHosts =
    ''
      178.62.54.226  mazais
      192.168.1.205  reinis-pi
      192.168.1.124  debian-vbox
    '';

  time.timeZone = "Europe/Riga";

  nixpkgs.config = {
      allowUnfree = true;
  };

  services.redshift = {
      enable = true;
      latitude = "56.948889";
      longitude = "24.106389";
      temperature = {
          day = 5500;
          night = 3700;
      };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.reinis = {
    isNormalUser = true;
    uid = 1000;
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.09";

}
