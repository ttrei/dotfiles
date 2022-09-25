-- From https://www.reddit.com/r/neovim/comments/uq85hr/how_could_i_achieve_this_toggle_shortcut_in_lua/i96whcy/
function vim_opt_toggle(opt, on, off)
  if vim.opt[opt]:get() == off then
    vim.opt[opt] = on
    vim.notify(opt .. " = " .. tostring(on))
  else
    vim.opt[opt] = off
    vim.notify(opt .. " = " .. tostring(off))
  end
end
