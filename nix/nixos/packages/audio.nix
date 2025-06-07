{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    jack2
    qjackctl
    zynaddsubfx
  ];
}
