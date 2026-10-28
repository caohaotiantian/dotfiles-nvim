-- Keymaps. Leader groups: f=find, b=buffer, w=window, c=code, x=diagnostics,
-- d=debug (removed with DAP), g=git, t=terminal, u=ui toggles.
local map = vim.keymap.set
local pick = require("config.picker")
local git = require("config.git")

local function toggle_window(name, label)
  return function()
    local current = vim.wo[0][0][name]
    vim.wo[0][0][name] = not current
    vim.notify(label .. (current and " off" or " on"))
  end
end

-- Files ----------------------------------------------------------------
map("n", "<leader><space>", pick.files, { desc = "Find files" })
map("n", "<leader>ff", pick.files, { desc = "Find files" })
map("n", "<leader>fg", pick.grep, { desc = "Live grep" })
map("n", "<leader>fw", function() pick.grep(vim.fn.expand("<cword>")) end, { desc = "Grep word" })
map("n", "<leader>fb", pick.buffers, { desc = "Buffers" })
map("n", "<leader>fr", pick.recent, { desc = "Recent files" })
map("n", "<leader>fh", pick.help, { desc = "Help" })
map("n", "<leader>fk", pick.keymaps, { desc = "Keymaps" })
map("n", "<leader>e", "<cmd>Lexplore<cr>", { desc = "File explorer sidebar" })
map("n", "-", "<cmd>Explore<cr>", { desc = "Explore current directory" })

-- Writing and quitting ------------------------------------------------
map({ "n", "i", "v" }, "<C-s>", "<cmd>update<cr>", { desc = "Write file" })
map("n", "<leader>q", "<cmd>confirm quit<cr>", { desc = "Quit window" })
map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Force quit all" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<cr>", { desc = "Delete other buffers" })

-- Buffers and windows -------------------------------------------------
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<C-h>", "<C-w>h"); map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k"); map("n", "<C-l>", "<C-w>l")
map("n", "<leader>wv", "<C-w>v", { desc = "Split right" })
map("n", "<leader>ws", "<C-w>s", { desc = "Split below" })
map("n", "<leader>wq", "<C-w>q", { desc = "Close window" })
map("n", "<leader>wo", "<C-w>o", { desc = "Close other windows" })
map("n", "<leader>w=", "<C-w>=", { desc = "Equalize windows" })

-- Motions -------------------------------------------------------------
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "<C-d>", "<C-d>zz"); map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv"); map("n", "N", "Nzzzv")
map("n", "Y", "y$", { desc = "Yank to end of line" })
map("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Diagnostics and quickfix -------------------------------------------
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>xx", function() vim.diagnostic.setqflist() end, { desc = "Diagnostics to quickfix" })
map("n", "<leader>xl", function() vim.diagnostic.setloclist() end, { desc = "Diagnostics to loclist" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Open quickfix" })
map("n", "<leader>xQ", "<cmd>cclose<cr>", { desc = "Close quickfix" })
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix item" })
map("n", "[q", "<cmd>cprev<cr>", { desc = "Previous quickfix item" })

-- Git -----------------------------------------------------------------
map("n", "]h", function() git.nav_hunk(1) end, { desc = "Next git hunk" })
map("n", "[h", function() git.nav_hunk(-1) end, { desc = "Previous git hunk" })
map("n", "<leader>gb", git.blame, { desc = "Blame line" })
map("n", "<leader>gd", git.diff, { desc = "Diff against HEAD" })
map("n", "<leader>gs", function() vim.cmd("terminal git status") end, { desc = "git status" })

-- Terminal ------------------------------------------------------------
map("n", "<leader>tt", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      vim.api.nvim_set_current_win(win)
      vim.cmd.startinsert()
      return
    end
  end
  vim.cmd("botright split | terminal")
end, { desc = "Terminal" })

-- UI toggles ----------------------------------------------------------
map("n", "<leader>uw", toggle_window("wrap", "wrap"), { desc = "Wrap" })
map("n", "<leader>un", toggle_window("number", "number"), { desc = "Line numbers" })
map("n", "<leader>ul", toggle_window("list", "list"), { desc = "List characters" })
map("n", "<leader>us", toggle_window("spell", "spell"), { desc = "Spelling" })
map("n", "<leader>ud", function()
  local enabled = vim.diagnostic.config() and vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = not enabled })
  vim.notify("virtual text " .. (enabled and "off" or "on"))
end, { desc = "Inline diagnostics" })
