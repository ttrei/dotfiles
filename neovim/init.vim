lua << EOF
require('plugins')
-- On the very first startup of neovim there will be errors due to missing plugins.
-- Not sure why, but the initial packer.sync() is executed only after the following imports.
require('reinis')
EOF

source ~/.config/nvim/vimrc_legacy
