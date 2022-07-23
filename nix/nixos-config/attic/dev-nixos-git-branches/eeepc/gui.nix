{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    dmenu
    font-awesome
    glxinfo
    i3
    i3blocks
    i3status
    neovim
    st
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

    synaptics.enable = true;
  };

  # Extra fonts
  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      vistafonts
      source-code-pro
    ];
  };
}
