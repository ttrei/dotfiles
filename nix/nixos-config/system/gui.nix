{config, lib, pkgs, ...}:

{
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

  # services.redshift = {
  #     enable = true;
  #     latitude = "56.948889";
  #     longitude = "24.106389";
  #     temperature = {
  #         day = 5500;
  #         night = 3700;
  #     };
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Extra fonts
  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      vistafonts
      source-code-pro
    ];
  };

}
