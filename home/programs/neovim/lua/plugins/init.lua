return {
  -- LSP
  {
    "nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    after = function()
      require("plugins.lsp")
    end,
  },

  -- Telescope
  {
    "telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<leader>p", mode = "n" },
      { "<leader>g", mode = "n" },
      { "<leader>b", mode = "n" },
      { "<leader>h", mode = "n" },
      { "<leader>T", mode = "n" },
      { "<leader>t", mode = "n" },
      { "<leader>d", mode = "n" },
      { "<leader>s", mode = "n" },
    },
    after = function()
      require("plugins.telescope")
    end,
  },

  -- Lualine
  {
    "lualine.nvim",
    event = "DeferredUIEnter",
    after = function()
      require("plugins.lualine")
    end,
  },

  -- claudecode.nvim (custom overlay name uses dash). Loaded at startup so
  -- its IDE server is up for `/ide` in a Claude running in another pane.
  {
    "claudecode-nvim",
    event = "DeferredUIEnter",
    after = function()
      require("plugins.claudecode")
    end,
  },

  -- lazygit
  {
    "lazygit.nvim",
    cmd = "LazyGit",
    keys = { { "<leader>lg", mode = "n" } },
    after = function()
      vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
    end,
  },

  -- diffview
  {
    "diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>gd", mode = "n" },
      { "<leader>gh", mode = "n" },
      { "<leader>gc", mode = "n" },
    },
    after = function()
      require("plugins.diffview")
    end,
  },

}
