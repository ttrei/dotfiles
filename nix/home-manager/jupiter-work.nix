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
    jetbrains.idea-community
    jetbrains.pycharm-community
    kubectl
    kubelogin-oidc
    k9s
    python310Packages.pgsanity
    # teams # proprietary
    teams-for-linux # open-source fork
  ];

  programs.bash.enable = false;
}
