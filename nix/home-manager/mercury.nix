{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./without-nixos.nix
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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";
}
