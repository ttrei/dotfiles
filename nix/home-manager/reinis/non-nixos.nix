{
  config,
  pkgs,
  ...
}: {
  imports = [./common.nix];

  programs.bash.enable = false;
}
