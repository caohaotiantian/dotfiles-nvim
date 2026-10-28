-- Plugin-free Neovim configuration. Requires Neovim 0.12+ (0.11+ mostly works).
-- Load order matters: leader first, then options that other modules read.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")      -- vim.opt, diagnostics, colorscheme
require("config.autocmds")     -- native autocmd behaviour
require("config.keymaps")      -- global mappings (uses picker + git modules)
require("config.statusline").setup()
require("config.treesitter")   -- highlighting and folding from installed parsers
require("config.lsp")          -- vim.lsp.config / vim.lsp.enable

-- Optional machine-local overrides (git-ignored).
pcall(require, "config.local")
