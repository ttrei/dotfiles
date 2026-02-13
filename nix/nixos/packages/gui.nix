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
    ghostty
    gnumeric
    # inkscape
    kdiff3
    meld
    pavucontrol
    # picard
    unstable.qbittorrent
    quickemu
    qutebrowser
    signal-desktop
    st
    vlc
    # whatsapp-for-linux
  ];

  # Extra fonts
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      vista-fonts
      source-code-pro
    ];
  };
}
