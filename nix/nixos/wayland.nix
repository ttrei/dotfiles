{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    mako
    waybar
    wl-clipboard
    wofi
  ];

  services.displayManager.ly.enable = true;
  programs.niri.enable = true;
}
