{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    unstable.kodi
    spotify
    transmission
  ];
}
