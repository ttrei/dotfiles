vim.api.nvim_command(
  'command! -nargs=* -complete=command CmdOutput enew | call setline(".", split(execute(<q-args>), "\\n"))'
)
vim.api.nvim_command(
  'command! -nargs=* -complete=command CmdOutputTab tabnew | call setline(".", split(execute(<q-args>), "\\n"))'
)
