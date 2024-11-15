{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    unstable.anki
    chromium
    djview
    dmenu
    evince
    firefox
    font-awesome
    glxinfo
    i3pyblocks
    # inkscape
    kdiff3
    meld
    pavucontrol
    # picard
    python3Packages.i3ipc
    unstable.qbittorrent
    rofi
    st
    vlc
    xbindkeys
    xdotool
    xfce.thunar
    xfce.xfce4-terminal
    xorg.xev
    xorg.xmodmap
    xsel
    zathura
    zutty
  ];

  services.xserver = {
    enable = true;
    xkb.layout = "lv";
    xkb.variant = "apostrophe";

    displayManager = {
      lightdm.enable = true;
    };

    windowManager.i3.enable = true;
    # windowManager.i3.package = pkgs.unstable.i3;
  };

  services.displayManager = {
    defaultSession = "none+i3";
    autoLogin.enable = true;
    autoLogin.user = "reinis";
  };

  services.xserver.config = ''
    Section "InputClass"
      Identifier "evdev pointer catchall"
      MatchIsPointer "on"
      MatchDevicePath "/dev/input/event*"
      Driver "evdev"
      Option "AccelerationScheme" "none"
    EndSection
  '';
  # Enable touchpad support
  services.libinput.enable = true;

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
    packages = with pkgs; [
      vistafonts
      source-code-pro
    ];
  };
}
