-- Autocommands: builtin behaviour only.
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text.
autocmd("TextYankPost", {
  group = augroup("user_yank_highlight", { clear = true }),
  callback = function() vim.hl.on_yank({ timeout = 200 }) end,
})

-- Restore the cursor to the last edit position.
autocmd("BufReadPost", {
  group = augroup("user_last_location", { clear = true }),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, [["]])
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Create missing parent directories on write.
autocmd("BufWritePre", {
  group = augroup("user_auto_mkdir", { clear = true }),
  callback = function(args)
    if args.match:match("^%w%w+://") then return end
    local file = vim.uv.fs_realpath(args.match) or args.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Close throwaway windows with `q`.
autocmd("FileType", {
  group = augroup("user_close_with_q", { clear = true }),
  pattern = { "help", "man", "qf", "checkhealth", "startuptime", "lspinfo", "netrw" },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, desc = "Close window" })
  end,
})

-- Prose filetypes: wrap, spell, no list characters.
autocmd("FileType", {
  group = augroup("user_prose", { clear = true }),
  pattern = { "markdown", "text", "gitcommit", "asciidoc", "rst", "tex" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.list = false
    vim.opt_local.colorcolumn = ""
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = "nc"
  end,
})

-- Commit messages: 72-column body, no automatic comment wrapping surprises.
autocmd("FileType", {
  group = augroup("user_gitcommit", { clear = true }),
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.textwidth = 72
    vim.opt_local.colorcolumn = "72"
  end,
})

-- Terminal buffers: start in insert mode, drop the line numbers.
autocmd("TermOpen", {
  group = augroup("user_terminal", { clear = true }),
  callback = function(args)
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.list = false
    vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { buffer = args.buf, desc = "Leave terminal mode" })
    vim.cmd.startinsert()
  end,
})

-- Keep window layout sane after a resize.
autocmd("VimResized", {
  group = augroup("user_resize", { clear = true }),
  callback = function() vim.cmd("tabdo wincmd =") end,
})

-- Redraw the statusline when diagnostics change while idle.
autocmd("DiagnosticChanged", {
  group = augroup("user_diag_redraw", { clear = true }),
  callback = function() vim.cmd.redrawstatus() end,
})
