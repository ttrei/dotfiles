{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    unstable.anki
    chromium
    dbeaver-bin
    djview
    dmenu
    evince
    firefox
    font-awesome
    ghostty
    gnumeric
    # inkscape
    kdiff3
    meld
    pavucontrol
    # picard
    unstable.qbittorrent
    qutebrowser
    signal-desktop
    st
    vlc
    # whatsapp-for-linux
    zathura
  ];

  # Extra fonts
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      vistafonts
      source-code-pro
    ];
  };
}
