require('reinis.utils')

-- NOTE
-- These are equivalent, but the second approach defers the "require" until the
-- remap is actually used, improving startup.
-- vim.keymap.set('n', '<C-p>', require('fzf-lua').files)
-- vim.keymap.set('n', '<C-p>', function() require('fzf-lua').files() end)

vim.keymap.set('n', '<leader>rr', ':ReloadConfig<cr>:source $MYVIMRC<cr>')

vim.keymap.set('n', '<leader>bd', ':bdelete<cr>')
vim.keymap.set('n', '<leader>h', ':nohlsearch<cr>')
vim.keymap.set('n', '<leader>i', function() vim_opt_toggle('ignorecase', true, false) end)
vim.keymap.set('n', '<leader>u', ':UndotreeToggle<cr>')
vim.keymap.set('n', '<leader>w', function() vim_opt_toggle('wrap', true, false) end)

vim.keymap.set('n', '<c-p>', require('fzf-lua').files, { desc = 'Find files using fzf' })

-- Navigation
vim.keymap.set('n', '<c-l>', ':tabnext<cr>')
vim.keymap.set('n', '<c-h>', ':tabprevious<cr>')
vim.keymap.set('n', '<c-s-l>', ':tabmove+1<cr>')
vim.keymap.set('n', '<c-s-h>', ':tabmove-1<cr>')

vim.keymap.set('n', '<leader>,', require('fzf-lua').buffers)
vim.keymap.set('n', '<leader>fh', require('fzf-lua').command_history)
