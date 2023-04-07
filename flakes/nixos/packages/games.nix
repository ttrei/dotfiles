{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    unstable.lutris
  ];

  programs.steam.enable = true;

  hardware.xone.enable = true;
}
