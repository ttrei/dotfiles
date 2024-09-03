------ https://github.com/yacineMTB/dingllm.nvim

local system_prompt =
  'You should replace the code that you are sent, only following the comments. Do not talk at all. Only output valid code. Do not provide any backticks that surround the code. Never ever output backticks like this ```. Any comment that is asking you for something should be removed after you satisfy them. Other comments should left alone. Do not output backticks'
local helpful_prompt = 'You are a helpful assistant. What I have sent are my notes so far.'
local dingllm = require 'reinis.dingllm'

function anthropic_help()
  dingllm.invoke_llm_and_stream_into_editor({
    url = 'https://api.anthropic.com/v1/messages',
    model = 'claude-3-5-sonnet-20240620',
    api_key_name = 'ANTHROPIC_API_KEY',
    system_prompt = helpful_prompt,
    replace = false,
  }, dingllm.make_anthropic_spec_curl_args, dingllm.handle_anthropic_spec_data)
end

function anthropic_replace()
  dingllm.invoke_llm_and_stream_into_editor({
    url = 'https://api.anthropic.com/v1/messages',
    model = 'claude-3-5-sonnet-20240620',
    api_key_name = 'ANTHROPIC_API_KEY',
    system_prompt = system_prompt,
    replace = true,
  }, dingllm.make_anthropic_spec_curl_args, dingllm.handle_anthropic_spec_data)
end


vim.keymap.set({ 'n', 'v' }, '<leader>II', anthropic_help, { desc = 'llm anthropic_help' })
vim.keymap.set({ 'n', 'v' }, '<leader>ii', anthropic_replace, { desc = 'llm anthropic' })



------ https://github.com/yetone/avante.nvim

require('img-clip').setup ({})
require('copilot').setup ({})
-- require('render-markdown').setup ({})
require('avante_lib').load()
require('avante').setup ({})
-- --   ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
-- --   provider = "claude", -- Recommend using Claude
-- --   claude = {
-- --     endpoint = "https://api.anthropic.com",
-- --     model = "claude-3-5-sonnet-20240620",
-- --     temperature = 0,
-- --     max_tokens = 4096,
-- --   },
-- --   behaviour = {
-- --     auto_suggestions = false, -- Experimental stage
-- --     auto_set_highlight_group = true,
-- --     auto_set_keymaps = true,
-- --     auto_apply_diff_after_generation = false,
-- --     support_paste_from_clipboard = false,
-- --   },
-- --   mappings = {
-- --     --- @class AvanteConflictMappings
-- --     diff = {
-- --       ours = "co",
-- --       theirs = "ct",
-- --       all_theirs = "ca",
-- --       both = "cb",
-- --       cursor = "cc",
-- --       next = "]x",
-- --       prev = "[x",
-- --     },
-- --     suggestion = {
-- --       accept = "<M-l>",
-- --       next = "<M-]>",
-- --       prev = "<M-[>",
-- --       dismiss = "<C-]>",
-- --     },
-- --     jump = {
-- --       next = "]]",
-- --       prev = "[[",
-- --     },
-- --     submit = {
-- --       normal = "<CR>",
-- --       insert = "<C-s>",
-- --     },
-- --   },
-- --   hints = { enabled = true },
-- --   windows = {
-- --     ---@type "right" | "left" | "top" | "bottom"
-- --     position = "right", -- the position of the sidebar
-- --     wrap = true, -- similar to vim.o.wrap
-- --     width = 30, -- default % based on available width
-- --     sidebar_header = {
-- --       align = "center", -- left, center, right for title
-- --       rounded = true,
-- --     },
-- --   },
-- --   highlights = {
-- --     ---@type AvanteConflictHighlights
-- --     diff = {
-- --       current = "DiffText",
-- --       incoming = "DiffAdd",
-- --     },
-- --   },
-- --   --- @class AvanteConflictUserConfig
-- --   diff = {
-- --     autojump = true,
-- --     ---@type string | fun(): any
-- --     list_opener = "copen",
-- --   },
-- })
