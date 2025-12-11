{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    i3pyblocks
    glxinfo
    python3Packages.i3ipc
    rofi
    xbindkeys
    xdotool
    xfce.thunar
    xfce.xfce4-terminal
    xorg.xev
    xorg.xmodmap
    xorg.xwininfo
    xsel
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

  # Extra fonts
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      vista-fonts
      source-code-pro
    ];
  };
}
