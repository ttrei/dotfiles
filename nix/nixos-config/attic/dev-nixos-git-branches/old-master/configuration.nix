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
  boot.loader.grub.device = "nodev";

  boot.loader.grub.extraEntries = "
    menuentry 'Windows 7 (loader) (on /dev/sdb2)' --class windows --class os $menuentry_id_option 'osprober-chain-DEDC674CDC671DD1' {
      insmod part_msdos
      insmod ntfs
      set root='hd1,msdos2'
      if [ x$feature_platform_search_hint = xy ]; then
        search --no-floppy --fs-uuid --set=root --hint-bios=hd1,msdos2 --hint-efi=hd1,msdos2 --hint-baremetal=ahci1,msdos2  DEDC674CDC671DD1
      else
        search --no-floppy --fs-uuid --set=root DEDC674CDC671DD1
      fi
      parttool \${root} hidden-
      chainloader +1
    }
  ";

  networking.hostName = "reinis-nixos";
  networking.extraHosts =
    ''
      178.62.54.226  mazais
      192.168.1.205  reinis-pi
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
          enableAdobeFlash = false;
          icedtea = true;
      };
  };

  # Extra fonts
  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      vistafonts
    ];
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
    chromium
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
    mnemosyne
    mplayer
    myvim
    p7zip
    pandoc
    pass
    pwgen
    python
    rsync
    stow
    transmission_gtk
    tree
    unzip
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

  services.xserver.displayManager.slim.enable = false;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.windowManager.i3.enable = true;

  services.xserver.config = ''
    Section "InputClass"
      Identifier "evdev pointer catchall"
      MatchIsPointer "on"
      MatchDevicePath "/dev/input/event*"
      Driver "evdev"
      Option "AccelerationProfile" "-1"
      Option "AccelerationScheme" "none"
    EndSection
  '';

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
  system.stateVersion = "17.09";

}
