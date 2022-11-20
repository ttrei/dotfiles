{ config, pkgs, ... }:

# Inspired by https://gitlab.com/LongerHV/nixos-configuration

{
  programs.neovim = {
    enable = true;
    plugins = (with pkgs.vimPlugins; [
      packer-nvim
      nvim-treesitter.withAllGrammars
      # # The following approach failed to build on 2022-11-20 with a strange error:
      # #   error: The option `programs.neovim.plugins."[definition 1-entry 2]".__ignoreNulls' does not exist. Definition values:
      # #   - In `/home/reinis/dotfiles/nix/home-manager/reinis/config/neovim.nix': true
      # nvim-treesitter.withPlugins (plugins: with plugins; [
      #   bash
      #   c
      #   cpp
      #   dockerfile
      #   java
      #   json
      #   lua
      #   make
      #   markdown
      #   nix
      #   org
      #   python
      #   sql
      #   vim
      #   yaml
      #   zig
      # ])
    ]);
  };

  home.file = {
    ".config/nvim" = {
      recursive = true;
      source = ../../../../nvim;
    };
  };
}
