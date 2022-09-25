require('reinis.utils')

-- NOTE
-- These are equivalent, but the second approach defers the "require" until the
-- remap is actually used, improving startup.
-- vim.keymap.set('n', '<C-p>', require('fzf-lua').files)
-- vim.keymap.set('n', '<C-p>', function() require('fzf-lua').files() end)


vim.keymap.set('n', '<Leader>h', function() vim_opt_toggle('hlsearch', true, false) end)
vim.keymap.set('n', '<Leader>i', function() vim_opt_toggle('ignorecase', true, false) end)
vim.keymap.set('n', '<Leader>w', function() vim_opt_toggle('wrap', true, false) end)

vim.keymap.set('n', '<C-p>', require('fzf-lua').files, { desc = 'Find files using fzf' })
