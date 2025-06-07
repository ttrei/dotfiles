{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    lutris
  ];

  programs.steam.enable = true;

  hardware.xone.enable = true;
}
