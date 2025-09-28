{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    waybar
    wofi
  ];

  services.displayManager.ly.enable = true;
  programs.niri.enable = true;
}
