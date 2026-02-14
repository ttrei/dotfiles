{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.zellij = {
    enable = true;
    # Don't auto-start zellij when opening a terminal
    # enableBashIntegration = false;
    settings = {
      theme = "gruvbox-light";
    };
  };
}
