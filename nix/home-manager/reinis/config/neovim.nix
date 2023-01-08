{
  config,
  pkgs,
  ...
}:
# Inspired by https://gitlab.com/LongerHV/nixos-configuration
{
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      packer-nvim

      # TODO
      # harpoon

      ### colors
      # gruvbox
      gruvbox-material

      ### syntax, LSP
      cmp-nvim-lsp
      luasnip
      cmp-buffer
      cmp_luasnip
      cmp-path
      neomake
      nvim-cmp
      nvim-lspconfig
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
      nvim-treesitter-context
      nvim-treesitter-textobjects
      vim-nix
      # # These should be handled by treesitter, right?
      # xml.vim
      # vim-javascript
      # vim-markdown

      ### other
      fastfold
      fzf-lua
      # # I will go with fzf-lua for now - people say it has better performance than telescope.
      # # But should re-visit this decision if I notice some telescope feature I really want.
      # telescope-nvim
      undotree
      vim-fugitive
      vim-table-mode
    ];
  };

  home.file = {
    ".config/nvim" = {
      recursive = true;
      source = ../../../../nvim;
    };
  };
}
