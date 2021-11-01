# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
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
    '';

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  time.timeZone = "Europe/Riga";

  nixpkgs.config = {
      allowUnfree = true;

      firefox = {
          enableAdobeFlash = true;
          icedtea = true;
      };
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    let
        myvim = lib.overrideDerivation pkgs.vim_configurable (o: {
          gui = false;
          xterm_clipboard = true;
        });
    in
  with pkgs; [
    ag
    anki
    dmenu
    encfs
    evince
    file
    firefox
    gitAndTools.gitFull
    gnupg
    gnupg1compat
    gnutar
    i3
    i3status
    lynx
    meld
    mplayer
    p7zip
    pandoc
    pass
    python
    pwgen
    rsync
    stow
    transmission_gtk
    tree
    unzip
    myvim
    wget
    xfce.terminal
    xorg.xev
    xorg.xmodmap
    zip
  ];

  programs.bash.enableCompletion = true;

  services.openssh.enable = true;

  services.xserver.enable = true;
  services.xserver.layout = "lv";
  services.xserver.xkbVariant = "apostrophe";

  services.xserver.synaptics.enable = true;
  services.xserver.synaptics.twoFingerScroll = true;
  services.xserver.synaptics.minSpeed = "0.5";
  services.xserver.synaptics.maxSpeed = "2.0";
  services.xserver.synaptics.accelFactor = "0.05";

  services.xserver.displayManager.slim.enable = false;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.windowManager.i3.enable = true;

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
  system.stateVersion = "16.09";

}
