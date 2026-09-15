{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./home.nix
    ./with-nixos.nix
  ];

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "never";
  };

  services.polkit-gnome.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";
}
