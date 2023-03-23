-- https://github.com/hrsh7th/nvim-cmp#setup

local cmp = require'cmp'

cmp.setup({

  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ['<TAB>'] = cmp.mapping.confirm({ select = true }),
  }),

  sources = {
    { name = 'copilot', group_index = 2 },
    { name = 'nvim_lsp', group_index = 2 },
    { name = 'luasnip', group_index = 2 },
  },

  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },

})

-- https://github.com/hrsh7th/cmp-nvim-lsp/#setup
local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('lspconfig').pyright.setup {
  capabilities = capabilities
}
require('lspconfig').zls.setup {
  capabilities = capabilities
}
