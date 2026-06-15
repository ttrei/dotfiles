vim.api.nvim_command(
  'command! -nargs=* -complete=command CmdOutput enew | call setline(".", split(execute(<q-args>), "\\n"))'
)
vim.api.nvim_command(
  'command! -nargs=* -complete=command CmdOutputTab tabnew | call setline(".", split(execute(<q-args>), "\\n"))'
)

-- https://www.reddit.com/r/neovim/comments/puuskh/how_to_reload_my_lua_config_while_using_neovim/he5vnqc/
function _G.ReloadConfig()
  for name, _ in pairs(package.loaded) do
    if name:match("^reinis") then
      package.loaded[name] = nil
    end
  end
end

vim.api.nvim_create_user_command("ReloadConfig", _G.ReloadConfig, { force = true })

-- Toggle textwidth between 80 and 120 and report the new value.
-- Useful when handling files with different conventions of where to break lines.
vim.api.nvim_create_user_command("ToggleTextWidth", function()
  if vim.bo.textwidth == 80 then
    vim.bo.textwidth = 120
  else
    vim.bo.textwidth = 80
  end
  print("textwidth=" .. vim.bo.textwidth)
end, { force = true })

-- no numbers --> absolute line numbers --> relative line numbers + absolute for current line
vim.api.nvim_create_user_command("NumberToggle", function()
  if vim.wo.number and vim.wo.relativenumber then
    vim.wo.relativenumber = false
    vim.wo.number = false
  elseif vim.wo.number and not vim.wo.relativenumber then
    vim.wo.relativenumber = true
  elseif not vim.wo.number and vim.wo.relativenumber then
    vim.wo.number = true
  else
    vim.wo.number = true
  end
end, { force = true })
