-- Stuff from legacy config:
--
-- "https://github.com/vim/vim/issues/993#issuecomment-255651605
-- let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
-- let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
--
-- if ( match(hostname(), '.*lenovo.*') >= 0 )
  -- let g:gruvbox_contrast_light="soft"
-- else
  -- let g:gruvbox_contrast_light="hard"
-- endif

vim.opt.termguicolors = true
vim.opt.background = 'light'
-- vim.opt.background = 'dark'

-- See ':help gruvbox-material' for configuration options
vim.g.gruvbox_material_background = 'hard' -- 'hard', 'medium', 'soft'
vim.g.gruvbox_material_foreground = 'original' -- 'material', 'mix', 'original'
vim.g.gruvbox_material_ui_contrast = 'high'
vim.g.gruvbox_material_visual = 'reverse'
vim.g.gruvbox_material_sign_column_background = 'grey'
vim.g.gruvbox_material_disable_italic_comment = 1
vim.cmd("colorscheme gruvbox-material")

local hl = function(name, opts)
    vim.api.nvim_set_hl(0, name, opts)
end

hl("DiffDelete", {
  reverse=true,
  fg='#928374', -- gray_245 gruvbox color
  bg='#f9f5d7', -- light0_hard gruvbox color
})

--[[
--
-- Copied from https://github.com/ThePrimeagen/.dotfiles/blob/master/nvim/.config/nvim
-- Do I want to set any of these?

hl("SignColumn", {
    bg = "none",
})

hl("ColorColumn", {
    ctermbg = 0,
    bg = "#555555",
})

hl("CursorLineNR", {
    bg = "None"
})

hl("Normal", {
    bg = "none"
})

hl("LineNr", {
    fg = "#5eacd3"
})

hl("netrwDir", {
    fg = "#5eacd3"
})

--]]
