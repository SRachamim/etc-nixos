-- Claude runs in its own tmux pane and attaches with `/ide`, so the plugin
-- opens no terminal split.
require("claudecode").setup({
  terminal = { provider = "none" },
})
vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send selection to Claude" })
vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add buffer to Claude" })
