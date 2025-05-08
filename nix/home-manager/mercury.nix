{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
  ];

  home.packages = with pkgs; [
    dbeaver-bin
    jetbrains.idea-community-bin
    jetbrains.pycharm-community-bin
    kubectl
    kubelogin-oidc
    k9s
    python310Packages.pgsanity
    stern
  ];

  programs.bash.enable = true;
}
