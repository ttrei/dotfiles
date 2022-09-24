-- Indenting
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.hlsearch = false

-- From https://www.reddit.com/r/neovim/comments/uq85hr/how_could_i_achieve_this_toggle_shortcut_in_lua/i96whcy/
local function vim_opt_toggle(opt, on, off, name)
  local message = name
  if vim.opt[opt]:get() == off then
    vim.opt[opt] = on
    message = message .. " Enabled"
  else
    vim.opt[opt] = off
    message = message .. " Disabled"
  end
  vim.notify(message)
end

vim.keymap.set('n', '<Leader>h', function() vim_opt_toggle('hlsearch', true, false, 'HighlightSearch') end)
