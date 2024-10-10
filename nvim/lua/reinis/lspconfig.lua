-- https://github.com/neovim/nvim-lspconfig
-- https://github.com/hrsh7th/cmp-nvim-lsp/#setup
--
local capabilities = require("cmp_nvim_lsp").default_capabilities()
require("lspconfig").clangd.setup({ capabilities = capabilities })
require("lspconfig").pylsp.setup({ capabilities = capabilities })
-- require("lspconfig").pyright.setup({ capabilities = capabilities })
require("lspconfig").superhtml.setup({ capabilities = capabilities })
require("lspconfig").ts_ls.setup({ capabilities = capabilities })
require("lspconfig").zls.setup({ capabilities = capabilities })
require("lspconfig").zls.setup({ capabilities = capabilities })

-- require'lspconfig'.rust_analyzer.setup{
--     -- Server-specific settings...
--     settings = {
--       ["rust-analyzer"] = {}
--     }
-- }
