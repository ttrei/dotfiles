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
    kubectl
    kubelogin-oidc
    k9s
    python310Packages.pgsanity
  ];

  programs.bash.enable = true;
}
