# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./mesa_drivers.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/disk/by-id/wwn-0x55cd2e404ba3235d";

  boot.kernelPackages = pkgs.linuxPackages_4_14;

  boot.kernelParams = [
    #"radeon.dpm=0"
    #"acpi=off"
  ];

  boot.loader.grub.extraEntries = "
    menuentry 'Windows 10 (loader) (on /dev/sdb1)' --class windows --class os $menuentry_id_option 'osprober-chain-C8560EFF560EEE4E' {
      insmod part_msdos
      insmod ntfs
      set root='hd1,msdos1'
      if [ x$feature_platform_search_hint = xy ]; then
        search --no-floppy --fs-uuid --set=root --hint-bios=hd1,msdos1 --hint-efi=hd1,msdos1 --hint-baremetal=ahci1,msdos1  C8560EFF560EEE4E
      else
        search --no-floppy --fs-uuid --set=root C8560EFF560EEE4E
      fi
      parttool \${root} hidden-
      drivemap -s (hd0) \${root}
      chainloader +1
    }
    menuentry 'Debian GNU/Linux' --class debian --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-simple-c7811fa3-3cc2-47c0-b2b4-9768bc7a8cfe' {
      insmod gzio
      if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi
      insmod part_msdos
      insmod ext2
      set root='hd2,msdos1'
      if [ x$feature_platform_search_hint = xy ]; then
        search --no-floppy --fs-uuid --set=root --hint-bios=hd2,msdos1 --hint-efi=hd2,msdos1 --hint-baremetal=ahci2,msdos1  c7811fa3-3cc2-47c0-b2b4-9768bc7a8cfe
      else
        search --no-floppy --fs-uuid --set=root c7811fa3-3cc2-47c0-b2b4-9768bc7a8cfe
      fi
      linux	/vmlinuz root=UUID=c7811fa3-3cc2-47c0-b2b4-9768bc7a8cfe ro  quiet
      initrd	/initrd.img
    }
  ";

  networking.hostName = "reinis-nixos";
  networking.extraHosts = ''
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
  environment.systemPackages = let
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
      obnam
      p7zip
      pandoc
      pass
      picard
      python
      pwgen
      rsync
      sshfsFuse
      stow
      thunderbird
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
      Option "ButtonMapping" "1 2 3 4 5 6 7 0 0 0 11 12 13 14 15 16"
    EndSection
  '';

  services.printing = {
    enable = true;
    drivers = [pkgs.gutenprint];
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
  system.stateVersion = "17.09";
}
