{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    alacritty
    unstable.anki
    chromium
    dbeaver-bin
    djview
    dmenu
    evince
    firefox
    font-awesome
    ghostty
    glxinfo
    gnumeric
    i3pyblocks
    # inkscape
    kdiff3
    meld
    pavucontrol
    # picard
    python3Packages.i3ipc
    unstable.qbittorrent
    qutebrowser
    rofi
    signal-desktop
    st
    vlc
    # whatsapp-for-linux
    xbindkeys
    xdotool
    xfce.thunar
    xfce.xfce4-terminal
    xorg.xev
    xorg.xmodmap
    xorg.xwininfo
    xsel
    waybar
    zathura
    zutty
  ];

  nixpkgs.config.chromium = {
    enableWideVine = true;
  };

  # services.xserver = {
  #   enable = true;
  #   xkb.layout = "lv";
  #   xkb.variant = "apostrophe";

  #   displayManager = {
  #     lightdm.enable = true;
  #   };

  #   windowManager.i3.enable = true;
  #   # windowManager.i3.package = pkgs.unstable.i3;
  # };

  services.displayManager.ly.enable = true;

  # programs.hyprland.enable = true;

  programs.niri.enable = true;

  # services.displayManager = {
  #   defaultSession = "none+i3";
  #   autoLogin.enable = true;
  #   autoLogin.user = "reinis";
  # };

  # services.xserver.config = ''
  #   Section "InputClass"
  #     Identifier "evdev pointer catchall"
  #     MatchIsPointer "on"
  #     MatchDevicePath "/dev/input/event*"
  #     Driver "evdev"
  #     Option "AccelerationScheme" "none"
  #   EndSection
  # '';
  # # Enable touchpad support
  # services.libinput.enable = true;

  # Extra fonts
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      vistafonts
      source-code-pro
    ];
  };
}
