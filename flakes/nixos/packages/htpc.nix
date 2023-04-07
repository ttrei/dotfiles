{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    kodi
    spotify
    transmission
  ];
}
