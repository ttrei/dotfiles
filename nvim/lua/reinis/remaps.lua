require('reinis.utils')

vim.keymap.set('n', '<Leader>h', function() vim_opt_toggle('hlsearch', true, false) end)
vim.keymap.set('n', '<Leader>i', function() vim_opt_toggle('ignorecase', true, false) end)
