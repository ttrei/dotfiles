-- Indent
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Search
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.wrapscan = false
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Undo, History
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.local/share/nvim/undodir/"
vim.opt.undofile = true

-- Window management
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.diffopt = 'internal,filler,closeoff'

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldenable = false -- No folding on startup

vim.opt.hidden = true -- Allow hidden buffers with unsaved changes
vim.opt.scrolloff = 3
vim.opt.wrap = false

vim.opt.mouse = ""

vim.opt.colorcolumn = { 80, 120 }
vim.opt.cursorline = true

--- Reserve a column on the left for linter hints.
--- I will not use it yet, but might come in handy.
-- vim.opt.signcolumn = 'yes'

vim.g.mapleader = " "
