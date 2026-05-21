-- Leader must be set BEFORE lazy loads (plugins capture <leader> at load time).
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.termguicolors = true
opt.signcolumn = "yes" -- always show signcolumn so text doesn't jump
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.splitright = true
opt.splitbelow = true
opt.winborder = "rounded" -- Neovim 0.11+ default float border
opt.undofile = true       -- persistent undo
opt.swapfile = false
opt.backup = false
opt.updatetime = 250 -- faster CursorHold for gitsigns/LSP
opt.timeoutlen = 400 -- which-key responsiveness
opt.completeopt = "menu,menuone,noselect"
opt.pumheight = 12
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- yank/paste uses system clipboard
opt.foldlevel = 99
opt.foldlevelstart = 99

vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  virtual_text = { current_line = true, prefix = "●" },
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.INFO]  = "",
      [vim.diagnostic.severity.HINT]  = "",
    }
  },
})
