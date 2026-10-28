-- Editor options. No plugins: everything here is a builtin Neovim option.
local opt = vim.opt
local fn = vim.fn

-- Editing behaviour ---------------------------------------------------------
opt.hidden = true                    -- keep modified buffers in memory when switching
opt.confirm = true                   -- ask instead of failing on :q with unsaved changes
opt.undofile = true                  -- persistent undo
opt.undodir = fn.stdpath("state") .. "/undo"
opt.swapfile = false
opt.backup = false
opt.updatetime = 200                 -- faster CursorHold (diagnostics, highlight)
opt.timeoutlen = 300                 -- leader / mapping timeout
opt.ttimeoutlen = 10                 -- key-code timeout (fast <Esc>)
opt.mouse = "a"
opt.mousemoveevent = false
opt.clipboard = "unnamedplus"        -- macOS: core has a clipboard provider
opt.jumpoptions = "view"             -- keep the view when jumping between buffers
opt.virtualedit = "block"            -- block selection may leave the line
opt.formatoptions = "jcroqlnt"       -- comment continuation, gq, numbered lists
opt.spelllang = "en_us"
opt.spelloptions = "camel"
opt.complete = ".,w,b,u"             -- no tags (slow, rarely used)
opt.completeopt = "menuone,noselect,popup,fuzzy"

-- Indentation (filetype plugins override per language) ----------------------
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.shiftround = true                -- >> indents to a multiple of shiftwidth
opt.autoindent = true
opt.smartindent = true
opt.breakindent = true

-- Search and grep -----------------------------------------------------------
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.inccommand = "split"             -- live preview of :s
opt.path:append("**")                -- :find works recursively
opt.suffixesadd:append({ ".lua", ".py", ".ts", ".rs" })
opt.grepprg = "rg --vimgrep --smart-case --no-heading --hidden --glob !.git"
opt.grepformat = "%f:%l:%c:%m"
opt.wildignore:append({ "*/node_modules/*", "*/.git/*", "*/target/*", "*/dist/*", "*/__pycache__/*" })
opt.wildmode = "longest:full,full"
opt.wildoptions = "pum"

-- Windows and UI ------------------------------------------------------------
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false                     -- text filetypes turn this on
opt.linebreak = true
opt.showbreak = "↳ "
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", extends = "›", precedes = "‹" }
opt.fillchars = { eob = " ", fold = " ", foldopen = "▾", foldclose = "▸", diff = "╱", vert = "│" }
opt.foldcolumn = "auto"              -- fold gutter only while folds exist
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldmethod = "manual"            -- treesitter switches to expr per buffer
opt.laststatus = 3                   -- one global statusline
opt.showtabline = 0
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"             -- no scroll jumps when splitting
opt.winborder = "rounded"            -- default float border
opt.pumheight = 12
opt.termguicolors = true
opt.background = "dark"
opt.diffopt = (vim.o.diffopt:gsub(",?linematch:%d+", "")) .. ",linematch:60" -- word-level diff

vim.fn.mkdir(opt.undodir:get()[1], "p")

-- Netrw ships with Neovim; used as the file explorer (see `<leader>e`, `-`).
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3            -- tree view
vim.g.netrw_winsize = 30
vim.g.netrw_altv = 1
vim.g.netrw_fastbrowse = 0           -- always rescan: correct after git operations

-- Diagnostics ---------------------------------------------------------------
local severity = vim.diagnostic.severity
vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  virtual_text = { current_line = true, prefix = "●", spacing = 2, source = false },
  underline = { severity = { min = severity.WARN } },
  float = { border = "rounded", source = true, header = "", prefix = "" },
  jump = { float = true, wrap = true },
  signs = {
    text = {
      [severity.ERROR] = "",
      [severity.WARN] = "",
      [severity.INFO] = "",
      [severity.HINT] = "",
    },
    numhl = {
      [severity.ERROR] = "DiagnosticSignError",
      [severity.WARN] = "DiagnosticSignWarn",
    },
  },
})

-- Colorscheme: one of the themes shipped in $VIMRUNTIME/colors.
pcall(vim.cmd.colorscheme, "habamax")
