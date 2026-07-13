require("avante_lib").load()
require("avante").setup({
  provider = "claude",
  claude = {
    model = "claude-sonnet-4-20250514",
    max_tokens = 8192,
  },
  behaviour = {
    auto_suggestions = false,
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
  },
  mappings = {
    ask = "<leader>aa",
    edit = "<leader>ae",
    refresh = "<leader>ar",
  },
})
