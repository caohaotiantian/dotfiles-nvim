-- Native statusline: the `statusline` option plus `v:lua` callbacks.
-- Highlight groups are written statically: a `%#group#` sequence returned from a
-- `%{...}` callback is inserted as literal text, not interpreted.
local M = {}

-- `v:lua.Statusline.*` needs a global table.
_G.Statusline = M

local hl = vim.api.nvim_set_hl
hl(0, "SlMode", { link = "Cursor" })
hl(0, "SlError", { link = "DiagnosticError" })
hl(0, "SlWarn", { link = "DiagnosticWarn" })
hl(0, "SlLsp", { link = "DiagnosticHint" })
hl(0, "SlSearch", { link = "Search" })

local mode_names = {
  n = "NORMAL",
  i = "INSERT",
  v = "VISUAL",
  V = "V-LINE",
  ["\22"] = "V-BLOCK",
  R = "REPLACE",
  c = "COMMAND",
  t = "TERMINAL",
  s = "SELECT",
  S = "S-LINE",
  ["\19"] = "S-BLOCK",
}

function M.mode()
  local mode = vim.api.nvim_get_mode().mode
  return mode_names[mode] or mode_names[mode:sub(1, 1)] or mode
end

function M.errors()
  local count = vim.diagnostic.count(0)[vim.diagnostic.severity.ERROR]
  return count and ("E" .. count .. " ") or ""
end

function M.warnings()
  local count = vim.diagnostic.count(0)[vim.diagnostic.severity.WARN]
  return count and ("W" .. count .. " ") or ""
end

function M.lsp()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then return "" end
  local names = {}
  for _, client in ipairs(clients) do names[#names + 1] = client.name end
  return table.concat(names, ",") .. " "
end

function M.search()
  if vim.v.hlsearch == 0 then return "" end
  local ok, count = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 100 })
  if not ok or type(count) ~= "table" or (count.total or 0) == 0 then return "" end
  if count.total > count.maxcount then return "" end
  return ("[%d/%d]"):format(count.current, count.total)
end

function M.setup()
  vim.o.statusline = table.concat({
    "%#SlMode# %{v:lua.Statusline.mode()} %*",
    " %<%f%m%r%w",
    "%#SlSearch#%{v:lua.Statusline.search()}%*",
    "%=",
    "%#SlError#%{v:lua.Statusline.errors()}%*",
    "%#SlWarn#%{v:lua.Statusline.warnings()}%*",
    "%#SlLsp#%{v:lua.Statusline.lsp()}%*",
    "%y %{&fileformat}",
    " %p%%",
    " %l:%c ",
  })
end

return M
