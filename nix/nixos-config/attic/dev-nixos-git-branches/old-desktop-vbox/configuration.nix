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
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.initrd.checkJournalingFS = false;

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.hostName = "reinis-nixos-vbox";
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
    obnam
    p7zip
    pandoc
    pass
    picard
    pwgen
    python
    rsync
    sshfsFuse
    stow
    thunderbird
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


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.reinis = {
    isNormalUser = true;
    uid = 1000;
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.09";

}
