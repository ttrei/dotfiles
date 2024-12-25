{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    alsa-utils
    spotify
    transmission
  ];
}
