-- https://github.com/nvim-treesitter/nvim-treesitter#modules
require'nvim-treesitter.configs'.setup {
  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

--[[
-- 2022-09-26 Seems that I don't need this workaround
--
---WORKAROUND
-- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation/b99d9ac6229535f4f7cf2cd87c588d6768878b71#packernvim
vim.api.nvim_create_autocmd({'BufEnter','BufAdd','BufNew','BufNewFile','BufWinEnter'}, {
  group = vim.api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
  callback = function()
    vim.opt.foldmethod     = 'expr'
    vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
  end
})
---ENDWORKAROUND
--]]
