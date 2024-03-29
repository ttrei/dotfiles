-- https://github.com/neovim/nvim-lspconfig/tree/d4eb971db353ccf78cefb3be1b05483b69ec1e69#suggested-configuration

--[[ TODO

* Java language server
https://zignar.net/2019/11/21/setup-neovim-for-java-development/
https://zignar.net/2020/10/17/setup-neovim-for-java-development-2/
https://github.com/eclipse/eclipse.jdt.ls

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#jdtls
Note: language server fails to start (Client 1 quit with exit code 13 and signal 0)
There is also the nvim-jdtls plugin - I tried it and it had the same problem.

--]]

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set("n", "<space>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
  vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
  vim.keymap.set("n", "<space>f", vim.lsp.buf.formatting, bufopts)
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}
require("lspconfig").clangd.setup({
  on_attach = on_attach,
  flags = lsp_flags,
})
require("lspconfig").jdtls.setup({
  on_attach = on_attach,
  flags = lsp_flags,
  cmd = { "jdt-language-server" },
})
require("lspconfig").pyright.setup({
  on_attach = on_attach,
  flags = lsp_flags,
})
require("lspconfig").tsserver.setup({
  on_attach = on_attach,
  flags = lsp_flags,
})
require("lspconfig").zls.setup({
  on_attach = on_attach,
  flags = lsp_flags,
})

-- require'lspconfig'.rust_analyzer.setup{
--     on_attach = on_attach,
--     flags = lsp_flags,
--     -- Server-specific settings...
--     settings = {
--       ["rust-analyzer"] = {}
--     }
-- }
