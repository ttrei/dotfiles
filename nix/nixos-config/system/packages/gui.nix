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
    i3pyblocks
    i3status
    # inkscape
    kdiff3
    meld
    neovim
    # picard
    python3Packages.i3ipc
    rofi
    st
    transmission-gtk
    vlc
    xbindkeys
    xfce.xfce4-terminal
    xorg.xev
    xorg.xmodmap
    xsel
    zathura
    zutty
  ];

  services.xserver = {
    enable = true;
    layout = "lv";
    xkbVariant = "apostrophe";

    displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "reinis";
      lightdm.enable = true;
    };

    windowManager.i3.enable = true;
    displayManager.defaultSession = "none+i3";
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
  # Enable touchpad support
  services.xserver.libinput.enable = true;

  location = {
      latitude = 56.948889;
      longitude = 24.106389;
  };

  # services.redshift = {
  #     enable = true;
  #     temperature = {
  #         day = 5500;
  #         night = 3700;
  #     };
  # };

  # Extra fonts
  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      vistafonts
      source-code-pro
    ];
  };
}
