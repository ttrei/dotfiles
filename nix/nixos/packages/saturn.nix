{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    alsa-utils
    git
    spotify
  ];
}
