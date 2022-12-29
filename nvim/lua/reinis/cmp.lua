-- https://github.com/hrsh7th/nvim-cmp#setup

local cmp = require'cmp'

cmp.setup({
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }, {
    { name = 'buffer' },
  })
})

-- https://github.com/hrsh7th/cmp-nvim-lsp/#setup
local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('lspconfig').pyright.setup {
  capabilities = capabilities
}
