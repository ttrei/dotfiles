{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    kodi
    transmission
  ];
}
