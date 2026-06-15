vim.filetype.add({
  pattern = {
    [".*%.html"] = "html",
    [".*%.html.j2"] = "html",
    [".*%.html.jinja2"] = "html",
  },
})

local filetype_settings = vim.api.nvim_create_augroup("VIMRC_FILETYPE_SETTINGS", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = filetype_settings,
  pattern = "*",
  callback = function()
    -- Disable automatic wrapping while typing and automatic re-formatting when joining comment lines.
    vim.opt_local.formatoptions:remove({ "t", "c", "j" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = filetype_settings,
  pattern = "asciidoc",
  callback = function()
    vim.opt_local.foldexpr = "NestedAsciidocFolds()"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = filetype_settings,
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.foldmethod = "syntax"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = filetype_settings,
  pattern = { "html", "htmldjango" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.foldmethod = "indent"
    vim.opt_local.tabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = filetype_settings,
  pattern = { "javascript", "json", "lua", "vue" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = filetype_settings,
  pattern = "xml",
  callback = function()
    vim.opt_local.foldmethod = "indent"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = filetype_settings,
  pattern = "yaml",
  callback = function()
    vim.opt_local.formatoptions:append("j")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = filetype_settings,
  pattern = "nix",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.foldmethod = "syntax"
    vim.opt_local.tabstop = 2
  end,
})

-- Open all folds
vim.api.nvim_create_autocmd("BufRead", {
  group = filetype_settings,
  pattern = "*",
  callback = function()
    pcall(vim.cmd.normal, "zR")
  end,
})
