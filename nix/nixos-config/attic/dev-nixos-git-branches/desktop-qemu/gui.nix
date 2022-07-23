{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    chromium
    djview
    dmenu
    evince
    firefox
    font-awesome
    glxinfo
    i3
    i3blocks
    i3status
    inkscape
    kdiff3
    meld
    mnemosyne
    neovim
    picard
    st
    thunderbird
    transmission_gtk
    vlc
    xfce.terminal
    xorg.xev
    xorg.xmodmap
    xsel
  ];

  services.xserver = {
    enable = true;
    layout = "lv";
    xkbVariant = "apostrophe";

    displayManager.lightdm = {
      enable = true;
      autoLogin.enable = true;
      autoLogin.user = "reinis";
    };

    windowManager.i3.enable = true;
    displayManager.defaultSession = "none+i3";
  };

  # Extra fonts
  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      vistafonts
      source-code-pro
    ];
  };

  nixpkgs.config = {
    firefox = {
      enableAdobeFlash = false;
      icedtea = true;
    };
  };
}
