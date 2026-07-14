vim.g.mapleader = " "

vim.opt.laststatus = 2
vim.opt.showmode = true
vim.opt.hlsearch = true
vim.opt.lazyredraw = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.wrapscan = true
vim.opt.report = 0
vim.opt.synmaxcol = 200
vim.opt.encoding = "utf-8"
vim.opt.autoread = true
vim.opt.number = true
vim.opt.termguicolors = true
vim.opt.swapfile = false
vim.opt.breakindent = true
vim.opt.cursorline = true
vim.opt.hidden = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.cmdheight = 2
vim.opt.updatetime = 300
vim.opt.shortmess:append("c")
vim.opt.signcolumn = "yes"
vim.opt.spelllang = "en_gb"

if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --no-heading"
  vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

vim.keymap.set("n", "<leader>l", ":nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr>", { silent = true, desc = "Clear highlights and redraw" })

-- Auto-reload files modified externally (e.g. by Claude Code or git)
local auto_reload = vim.api.nvim_create_augroup("AutoReload", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  group = auto_reload,
  callback = function()
    if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = auto_reload,
  callback = function()
    vim.notify("File changed on disk. Reloaded.", vim.log.levels.WARN)
  end,
})

-- Yank filepath:line or filepath:startline-endline to system clipboard
vim.keymap.set("n", "<leader>yp", function()
  local path = vim.fn.expand("%") .. ":" .. vim.fn.line(".")
  vim.fn.setreg("+", path)
  vim.notify("Yanked: " .. path)
end, { desc = "Yank filepath:line" })
vim.keymap.set("v", "<leader>yp", function()
  local path = vim.fn.expand("%") .. ":" .. vim.fn.line("'<") .. "-" .. vim.fn.line("'>")
  vim.fn.setreg("+", path)
  vim.notify("Yanked: " .. path)
end, { desc = "Yank filepath:range" })

-- Spotless auto-format for Java files
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.java",
  callback = function()
    local pom = vim.fn.findfile("pom.xml", ".;")
    if pom ~= "" then
      local filepath = vim.fn.expand("%:p")
      vim.fn.system("mvn spotless:apply -DspotlessFiles=" .. filepath)
      vim.cmd("edit!")
    end
  end,
})

-- Startup plugins (loaded from start/, no lz.n needed)
require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = true,
  term_colors = true,
  integrations = {
    cmp = true,
    treesitter = true,
    telescope = { enabled = true },
    diffview = true,
    native_lsp = { enabled = true },
  },
})
vim.cmd.colorscheme("catppuccin-mocha")
require("snacks").setup({})
require("plugins.treesitter")
require("plugins.agentic")
require("plugins.orgmode")

-- Load lz.n for lazy loading optional plugins
require("lz.n").load(require("plugins"))
