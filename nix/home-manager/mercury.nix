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
    ./without-nixos.nix
  ];

  home.packages = with pkgs; [
    dbeaver-bin
    # https://github.com/NixOS/nixpkgs/issues/182856#issuecomment-3009621304
    (google-cloud-sdk.withExtraComponents (
      with google-cloud-sdk.components;
      [
        gke-gcloud-auth-plugin
      ]
    ))
    jetbrains.idea-community-bin
    jetbrains.pycharm-community-bin
    kubectl
    kubelogin-oidc
    k9s
    postgresql
    python310Packages.pgsanity
    stern
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";
}
