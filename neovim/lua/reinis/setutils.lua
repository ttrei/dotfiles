-- From https://www.reddit.com/r/neovim/comments/uq85hr/how_could_i_achieve_this_toggle_shortcut_in_lua/i96whcy/
function vim_opt_toggle(opt, on, off, name)
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
