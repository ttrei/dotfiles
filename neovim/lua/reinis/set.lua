require('reinis.setutils')

-- Indent
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Search
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.keymap.set('n', '<Leader>h', function() vim_opt_toggle('hlsearch', true, false, 'hlsearch') end)
vim.opt.wrapscan = false
vim.opt.ignorecase = true
vim.keymap.set('n', '<Leader>i', function() vim_opt_toggle('ignorecase', true, false, 'ignorecase') end)
vim.opt.smartcase = true

vim.opt.hidden = true -- Allow hidden buffers with unsaved changes
vim.opt.wrap = false
