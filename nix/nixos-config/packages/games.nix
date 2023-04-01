{
  config,
  pkgs,
  ...
}: let
  unstable = import <nixos-unstable> {
    # https://github.com/NixOS/nixpkgs/issues/55366
    # Include the nixos config when importing nixos-unstable
    # But remove packageOverrides to avoid infinite recursion
    config = removeAttrs config.nixpkgs.config ["packageOverrides"];
  };
in {
  environment.systemPackages = with pkgs; [
    unstable.lutris
  ];

  programs.steam.enable = true;

  hardware.xone.enable = true;
}
