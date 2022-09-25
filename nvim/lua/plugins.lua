-- https://github.com/wbthomason/packer.nvim/tree/6afb67460283f0e990d35d229fd38fdc04063e0a#bootstrapping

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use 'https://github.com/dhruvasagar/vim-table-mode.git'
  use 'https://github.com/Konfekt/FastFold.git'
  use 'https://github.com/LnL7/vim-nix.git'
  use 'https://github.com/matcatc/vim-asciidoc-folding'
  -- use 'https://github.com/morhetz/gruvbox.git'
  use 'https://github.com/gruvbox-community/gruvbox.git'
  use 'https://github.com/neomake/neomake.git'
  use 'https://github.com/neovim/nvim-lspconfig.git'
  use 'https://github.com/othree/xml.vim.git'
  use 'https://github.com/pangloss/vim-javascript'
  use 'https://github.com/plasticboy/vim-markdown.git'
  use 'https://github.com/tpope/vim-fugitive.git'
  use 'https://github.com/ziglang/zig.vim.git'

  use {
    'https://github.com/nvim-treesitter/nvim-treesitter.git',
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
  }

  -- I will go with fzf-lua for now.
  -- But should re-visit this decision if I notice some feature I want from nvim-telescope.
  use 'https://github.com/ibhagwan/fzf-lua.git'
  -- use {
  --   'https://github.com/nvim-telescope/telescope.nvim.git', tag = '0.1.0',
  --   requires = { {'https://github.com/nvim-lua/plenary.nvim.git'} }
  -- }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
  -- You can also sync manually with :PackerSync
end)
