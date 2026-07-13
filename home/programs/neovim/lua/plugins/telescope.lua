local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup({
  defaults = {
    file_ignore_patterns = { "node_modules", ".git/" },
    mappings = {
      i = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
      },
    },
  },
  pickers = {
    find_files = { hidden = true },
    live_grep = { additional_args = function() return { "--hidden" } end },
  },
})

vim.keymap.set("n", "<leader>p", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>g", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>h", builtin.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>T", builtin.tags, { desc = "Tags" })
vim.keymap.set("n", "<leader>t", builtin.current_buffer_tags, { desc = "Buffer tags" })
vim.keymap.set("n", "<leader>d", builtin.diagnostics, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>s", builtin.lsp_document_symbols, { desc = "Document symbols" })
