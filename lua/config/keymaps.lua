local map = vim.keymap.set

-- Save / quit
map({ "n", "i", "v" }, "<C-s>", "<cmd>write<cr><esc>", { desc = "Write file" })
map("n", "<leader>fs", "<cmd>write<cr>", { desc = "Write file" })
map("n", "<leader>q", "<cmd>confirm quit<cr>", { desc = "Quit window" })
map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Force quit all" })

-- Window management
map("n", "<leader>wv", "<C-w>v", { desc = "Split right" })
map("n", "<leader>ws", "<C-w>s", { desc = "Split below" })
map("n", "<leader>wo", "<C-w>o", { desc = "Close other windows" })
map("n", "<leader>wq", "<C-w>q", { desc = "Close window" })
map("n", "<leader>w=", "<C-w>=", { desc = "Equalize windows" })

-- Escape clears search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Move by visual line on wrapped text
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Window navigation
map("n", "<C-h>", "<C-w>h"); map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k"); map("n", "<C-l>", "<C-w>l")

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Center the screen on jumps
map("n", "<C-d>", "<C-d>zz"); map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv"); map("n", "N", "Nzzzv")

-- Move selected lines in visual mode
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Paste without yanking the replaced text
map("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })
-- Explicit system-clipboard yank
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })

-- Diagnostics (Neovim 0.11+ API)
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
