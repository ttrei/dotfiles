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


-- Clipboard
if vim.fn.has('wsl') == 1 then
    vim.g.clipboard = {
        name = 'WslClipboard',
        copy = {
            ['+'] = 'clip.exe',
            ['*'] = 'clip.exe',
        },
        -- TODO: I don't want to override the paste behavior, the default is good enough, and powershell approach is slow.
        --       Commenting this section out doesn't work.
        paste = {
            ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        },
        cache_enabled = 0,
    }
end


-- Other

-- Allow selecting past end of line in Visual Block mode
vim.opt.virtualedit = "block"

-- While composing a substitution command, show the resulting substitutions in a separate split instead of the buffer
-- we are editing. Useful when the substitutions are all over a large file - can see more of them.
vim.opt.inccommand = "split"

vim.opt.diffopt = "internal,filler,closeoff"

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
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
