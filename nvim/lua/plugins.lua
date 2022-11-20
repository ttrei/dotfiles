-- https://github.com/wbthomason/packer.nvim/tree/6afb67460283f0e990d35d229fd38fdc04063e0a#bootstrapping

require('packer').startup(function(use)
  -- TODO
  -- use 'https://github.com/ThePrimeagen/harpoon.git'

  -- Colors
  use 'https://github.com/gruvbox-community/gruvbox.git'

  -- Syntax, LSP
  use 'https://github.com/neomake/neomake.git'
  use 'https://github.com/neovim/nvim-lspconfig.git'
  --[[
  -- These should be handled by treesitter, right?
  use 'https://github.com/othree/xml.vim.git'
  use 'https://github.com/pangloss/vim-javascript'
  use 'https://github.com/plasticboy/vim-markdown.git'
  use 'https://github.com/ziglang/zig.vim.git'
  --]]
  use 'https://github.com/matcatc/vim-asciidoc-folding'
  use 'https://github.com/LnL7/vim-nix.git'

  -- Git
  use 'https://github.com/tpope/vim-fugitive.git'

  -- Undo history
  use 'https://github.com/mbbill/undotree.git'

  -- Other
  -- TODO: Consider using the built-in visual star search instead
  use 'https://github.com/bronson/vim-visual-star-search.git'
  use 'https://github.com/dhruvasagar/vim-table-mode.git'
  use 'https://github.com/Konfekt/FastFold.git'

  -- Fuzzy finding
  use 'https://github.com/ibhagwan/fzf-lua.git'
  -- I will go with fzf-lua for now - people say it has better performance than telescope.
  -- But should re-visit this decision if I notice some telescope feature I really want.
  -- use {
  --   'https://github.com/nvim-telescope/telescope.nvim.git', tag = '0.1.0',
  --   requires = { {'https://github.com/nvim-lua/plenary.nvim.git'} }
  -- }
end)
