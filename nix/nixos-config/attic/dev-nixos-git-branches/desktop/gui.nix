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
    desktopManager.default = "none";
    windowManager.default = "i3";
  };

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
