lua << EOF
require('reinis')
EOF

runtime vimrc_legacy

" https://www.reddit.com/r/neovim/comments/puuskh/how_to_reload_my_lua_config_while_using_neovim/he5vnqc/
lua <<EOF
function _G.ReloadConfig()
  for name,_ in pairs(package.loaded) do
    if name:match('^reinis') then
      package.loaded[name] = nil
    end
  end
end
EOF
command! ReloadConfig lua ReloadConfig()

" Guide on migrating from vimscript to lua
" https://github.com/nanotee/nvim-lua-guide

" My neovim config is inspired by
" ThePrimeagen https://www.youtube.com/watch?v=DogKdiRx7ls
"   https://github.com/ThePrimeagen/.dotfiles/blob/master/nvim/.config/nvim
" Teej https://github.com/tjdevries/config_manager/tree/master/xdg_config/nvim
