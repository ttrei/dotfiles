require('reinis.setutils')

-- Indenting
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.hlsearch = false

vim.opt.hidden = true

vim.keymap.set('n', '<Leader>h', function() vim_opt_toggle('hlsearch', true, false, 'HighlightSearch') end)
