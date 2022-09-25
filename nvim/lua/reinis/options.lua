-- I'm mimicking the setup of ThePrimeagen:
-- https://www.youtube.com/watch?v=DogKdiRx7ls

-- Indent
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Search
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.wrapscan = false
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Undo, History
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.local/share/nvim/undodir/"
vim.opt.undofile = true

vim.opt.hidden = true -- Allow hidden buffers with unsaved changes
vim.opt.scrolloff = 8
vim.opt.wrap = false

--- Reserve a column on the left for linter hints.
--- I will not use it yet, but might come in handy.
-- vim.opt.signcolumn = 'yes'

vim.g.mapleader = " "
