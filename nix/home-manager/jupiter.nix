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
    ./with-nixos.nix
  ];

  home.packages = with pkgs; [
    unstable.aider-chat-full
    jetbrains.idea-community-bin
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";
}
