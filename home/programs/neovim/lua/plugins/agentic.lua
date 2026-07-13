require("agentic").setup({
  provider = "cursor-acp",
  debug = false,
  acp_providers = {
    ["cursor-acp"] = {
      name = "Cursor Agent ACP",
      command = vim.fn.expand("~/.npm-global/bin/cursor-agent-acp"),
      args = { "-c", vim.fn.expand("~/.config/cursor-agent-acp/config.json") },
      env = {
        NODE_NO_WARNINGS = "1",
        IS_AI_TERMINAL = "1",
        PATH = vim.fn.expand("~/.npm-global/bin") .. ":" .. vim.fn.expand("~/.local/bin") .. ":" .. vim.env.PATH,
        HOME = vim.fn.expand("~"),
      },
    },
  },
})
