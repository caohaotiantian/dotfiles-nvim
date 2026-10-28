-- Native git support: hunk signs from `git diff`, line blame, and a HEAD diff view.
local M = {}

local namespace = vim.api.nvim_create_namespace("user_git")
local augroup = vim.api.nvim_create_augroup("user_git", { clear = true })

vim.api.nvim_set_hl(0, "GitSignAdd", { link = "DiagnosticOk" })
vim.api.nvim_set_hl(0, "GitSignChange", { link = "DiagnosticWarn" })
vim.api.nvim_set_hl(0, "GitSignDelete", { link = "DiagnosticError" })

local signs = {
  add = { text = "▎", hl = "GitSignAdd" },
  change = { text = "▎", hl = "GitSignChange" },
  delete = { text = "▁", hl = "GitSignDelete" },
}

--- @return string? repo, string? relative
local function buffer_location(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" or vim.bo[bufnr].buftype ~= "" then return end
  local path = vim.fs.normalize(name)
  local repo = vim.fs.root(path, ".git")
  if not repo then return end
  local relative = vim.fs.relpath(vim.fs.normalize(repo), path)
  if not relative then return end
  return repo, relative
end

local function clear(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
end

local function apply_hunks(bufnr, output)
  clear(bufnr)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for line in output:gmatch("[^\n]+") do
    local old_start, old_count, new_start, new_count =
      line:match("^@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@")
    if old_start then
      local old_lines = old_count == "" and 1 or tonumber(old_count)
      local new_lines = new_count == "" and 1 or tonumber(new_count)
      local new_line = tonumber(new_start)
      local kind = new_lines == 0 and "delete" or (old_lines == 0 and "add" or "change")
      local row = math.min(math.max(new_line, 1), line_count) - 1
      local sign = signs[kind]
      vim.api.nvim_buf_set_extmark(bufnr, namespace, row, 0, {
        sign_text = sign.text,
        sign_hl_group = sign.hl,
        priority = 20,
      })
    end
  end
end

--- Recompute hunk signs for a buffer (async; disk state against HEAD).
function M.refresh(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  clear(bufnr)

  local repo, relative = buffer_location(bufnr)
  if not repo or vim.api.nvim_buf_line_count(bufnr) > 20000 then return end

  vim.system(
    { "git", "-C", repo, "diff", "--no-color", "--no-ext-diff", "--unified=0", "--", relative },
    { text = true },
    function(result)
      if result.code ~= 0 or result.stdout == "" then return end
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(bufnr) then apply_hunks(bufnr, result.stdout) end
      end)
    end
  )
end

--- Jump to the next (1) or previous (-1) hunk sign.
function M.nav_hunk(direction)
  local bufnr = vim.api.nvim_get_current_buf()
  local marks = vim.api.nvim_buf_get_extmarks(bufnr, namespace, 0, -1, {})
  if #marks == 0 then return vim.notify("git: no hunks in this buffer") end

  local line = vim.api.nvim_win_get_cursor(0)[1]
  local target
  if direction > 0 then
    for _, mark in ipairs(marks) do
      if mark[2] + 1 > line then target = mark[2] + 1; break end
    end
    target = target or marks[1][2] + 1
  else
    for index = #marks, 1, -1 do
      if marks[index][2] + 1 < line then target = marks[index][2] + 1; break end
    end
    target = target or marks[#marks][2] + 1
  end
  vim.api.nvim_win_set_cursor(0, { target, 0 })
end

local function open_float(lines, title)
  local width = 20
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line) + 2)
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = math.min(width, vim.o.columns - 4),
    height = #lines,
    style = "minimal",
    border = "rounded",
    title = " " .. title .. " ",
  })
  vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    end,
  })
end

--- Show `git blame` for the current line in a float.
function M.blame()
  local bufnr = vim.api.nvim_get_current_buf()
  local repo, relative = buffer_location(bufnr)
  if not repo then return vim.notify("git: not inside a repository") end

  local line = vim.api.nvim_win_get_cursor(0)[1]
  local output = vim.fn.systemlist({
    "git", "-C", repo, "blame", "--line-porcelain", "-L", ("%d,%d"):format(line, line), "--", relative,
  })
  if vim.v.shell_error ~= 0 then return vim.notify("git: blame failed") end

  local info = {}
  for _, entry in ipairs(output) do
    local key, value = entry:match("^(%S+) (.*)$")
    if key == "author" then
      info.author = value
    elseif key == "author-time" then
      info.time = tonumber(value)
    elseif key == "summary" then
      info.summary = value
    elseif key == "filename" then
      info.filename = value
    end
  end
  if not info.author then return vim.notify("git: no blame data") end

  open_float({
    ("%s  %s"):format(info.author, info.time and os.date("%Y-%m-%d", info.time) or "unknown"),
    info.summary or "",
    ("%s:%d"):format(info.filename or relative, line),
  }, "git blame")
end

--- Side-by-side diff of the buffer against HEAD (native :diffthis).
function M.diff()
  local bufnr = vim.api.nvim_get_current_buf()
  local repo, relative = buffer_location(bufnr)
  if not repo then return vim.notify("git: not inside a repository") end

  local head = vim.fn.systemlist({ "git", "-C", repo, "show", "HEAD:" .. relative })
  if vim.v.shell_error ~= 0 then return vim.notify("git: file is not tracked in HEAD") end

  local filetype = vim.bo[bufnr].filetype
  local origin = vim.api.nvim_get_current_win()
  vim.cmd("vertical topleft new")
  local scratch = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(scratch, 0, -1, false, head)
  vim.bo[scratch].buftype = "nofile"
  vim.bo[scratch].bufhidden = "wipe"
  vim.bo[scratch].swapfile = false
  vim.bo[scratch].filetype = filetype
  vim.cmd("diffthis")
  vim.api.nvim_win_call(origin, function() vim.cmd("diffthis") end)
  vim.api.nvim_set_current_win(origin)
end

for _, event in ipairs({ "BufReadPost", "BufWritePost", "BufFilePost" }) do
  vim.api.nvim_create_autocmd(event, {
    group = augroup,
    callback = function(args) M.refresh(args.buf) end,
  })
end

return M
