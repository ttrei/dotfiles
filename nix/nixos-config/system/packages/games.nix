{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    lutris
  ];

  programs.steam.enable = true;
}
