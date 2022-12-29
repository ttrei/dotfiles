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

  -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  textobjects = {
    -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects#text-objects-select
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects#built-in-textobjects
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
      selection_modes = {
        ['@parameter.outer'] = 'v', -- charwise
        ['@function.outer'] = 'V', -- linewise
        ['@function.inner'] = 'V', -- linewise
        ['@class.outer'] = 'V', -- blockwise
      },
      include_surrounding_whitespace = false,
    },
  },

  -- https://github.com/nvim-treesitter/nvim-treesitter#incremental-selection
  -- NOTE: Not using this for now - maybe nvim-treesitter-textobjects will cover all I need
  -- incremental_selection = {
  --   enable = true,
  --   keymaps = {
  --       init_selection = "<CR>",
  --       node_incremental = "<CR>",
  --       scope_incremental = false,
  --       node_decremental = "<BS>",
  --   },
  -- },
  -- NOTE: Other plugins for text selection based on treesitter AST
  -- I tried nvim-treesitter-textsubjects but didn't immediately see the value-add over the
  -- nvim-treesitter built-in incremental selection.
  -- https://github.com/RRethy/nvim-treesitter-textsubjects
  -- https://github.com/mfussenegger/nvim-treehopper

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
