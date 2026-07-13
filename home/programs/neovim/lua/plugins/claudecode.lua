require("claudecode").setup({
  terminal = {
    split_side = "right",
    split_width_percentage = 0.4,
  },
})
vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude Code" })
vim.keymap.set("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude Code" })
vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send selection to Claude" })
vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeTreeAdd buffer<cr>", { desc = "Add buffer to Claude" })
