-- https://github.com/neovim/nvim-lspconfig
-- https://github.com/hrsh7th/cmp-nvim-lsp/#setup
--
-- 2025-12:
-- https://gpanders.com/blog/whats-new-in-neovim-0-11/#simpler-lsp-setup-and-configuration

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- vim.lsp.config('clangd', { capabilities = capabilities })
vim.lsp.config('pylsp', { capabilities = capabilities })
-- vim.lsp.config('pyright', { capabilities = capabilities })
vim.lsp.config('superhtml', { capabilities = capabilities })
vim.lsp.config('ts_ls', { capabilities = capabilities })
vim.lsp.config('zls', { capabilities = capabilities })

-- vim.lsp.enable({'clangd'})
vim.lsp.enable({'pylsp'})
vim.lsp.enable({'superhtml'})
vim.lsp.enable({'ts_ls'})
vim.lsp.enable({'zls'})
