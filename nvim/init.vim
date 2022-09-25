lua << EOF
require('plugins')
-- On the very first startup of neovim there will be errors due to missing plugins.
-- Not sure why, but the initial packer.sync() is executed only after the following imports.
require('reinis')
EOF

source ~/.config/nvim/vimrc_legacy

" Guide on migrating from vimscript to lua
" https://github.com/nanotee/nvim-lua-guide

" My neovim config is inspired by
" ThePrimeagen https://www.youtube.com/watch?v=DogKdiRx7ls
" Teej https://github.com/tjdevries/config_manager/tree/master/xdg_config/nvim

" TODO
" * Move current line up or down (or move the whole visual selection? maybe overkill)
" * LSP stuff
" * undotree
