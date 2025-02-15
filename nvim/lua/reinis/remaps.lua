require("reinis.utils")

-- NOTE
-- These are equivalent, but the second approach defers the "require" until the
-- remap is actually used, improving startup.
-- vim.keymap.set('n', '<C-p>', require('fzf-lua').files)
-- vim.keymap.set('n', '<C-p>', function() require('fzf-lua').files() end)
-- you can pass arguments to methods, and add description:
-- vim.keymap.set("n", "<c-P>", function() require('fzf-lua').files({ ... }) end, { desc = "Fzf Files" })

-- Reload configuration from the default location.
vim.keymap.set("n", "<leader>cr", ":set runtimepath-=~/dotfiles/nvim<cr>:ReloadConfig<cr>:source $MYVIMRC<cr>")
-- Reload configuration straight from the dotfiles directory.
-- This allows for faster iteration when trying out configuration changes.
vim.keymap.set(
  "n",
  "<leader>crd",
  ":set runtimepath^=~/dotfiles/nvim<cr>:ReloadConfig<cr>:source ~/dotfiles/nvim/init.vim<cr>"
)

vim.keymap.set("n", "<leader>bd", ":bdelete<cr>")
vim.keymap.set("n", "<leader>h", ":nohlsearch<cr>")
vim.keymap.set("n", "<leader>i", function()
  vim_opt_toggle("ignorecase", true, false)
end)
vim.keymap.set("n", "<leader>u", ":UndotreeToggle<cr>")
vim.keymap.set("n", "<leader>w", function()
  vim_opt_toggle("wrap", true, false)
end)

vim.keymap.set("n", "<c-p>", function() require('fzf-lua').files({ git_icons = false }) end, { desc = "Find files using fzf" })

-- Navigation
vim.keymap.set("n", "<c-l>", ":tabnext<cr>")
vim.keymap.set("n", "<c-h>", ":tabprevious<cr>")
vim.keymap.set("n", "<c-s-l>", ":tabmove+1<cr>")
vim.keymap.set("n", "<c-s-h>", ":tabmove-1<cr>")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "norg",
  callback = function()
    vim.keymap.set("n", "<leader>nt", ":Neorg toggle-concealer<cr>", { buffer = true })
  end
})

vim.keymap.set("n", "<leader>,", require("fzf-lua").buffers)
vim.keymap.set("n", "<leader>fh", require("fzf-lua").command_history)

-- List loaded plugins
vim.keymap.set('n', '<Leader>p', "[[:new<CR>:put =execute('scriptnames')<CR>]]", { noremap = true, silent = true })

-- LSP (mappings suggested by Claude AI)
-- https://neovim.io/doc/user/lsp.html#_lua-module:-vim.lsp.buf
-- Info
local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
vim.api.nvim_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
-- Refactoring
vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
-- Diagnostic
vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
-- Optional: Telescope setup for better UI
-- local telescope = require('telescope.builtin')
-- vim.api.nvim_set_keymap('n', '<leader>fr', '<cmd>lua require("telescope.builtin").lsp_references()<CR>', opts)
-- vim.api.nvim_set_keymap('n', '<leader>fs', '<cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>', opts)
