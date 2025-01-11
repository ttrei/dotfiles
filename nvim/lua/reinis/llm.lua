------ https://github.com/yetone/avante.nvim

require('avante_lib').load()
require('avante').setup ({
  -- https://github.com/yetone/avante.nvim/wiki/Custom-providers#deepseek
  provider = "deepseek",
  vendors = {
    deepseek = {
      __inherited_from = "openai",
      api_key_name = "DEEPSEEK_API_KEY",
      endpoint = "https://api.deepseek.com",
      model = "deepseek-coder",
    },
  },
})
