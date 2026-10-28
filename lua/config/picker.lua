-- Native fuzzy pickers built on `git ls-files` / `rg` / `matchfuzzy()` / `vim.ui.select()`.
-- Two prompts (query, then choose) instead of a live window: no plugin, no polling loop.
local M = {}

local function notify(message)
  vim.notify("picker: " .. message, vim.log.levels.INFO)
end

--- Fuzzy-filter candidates with an interactive query, then let the user choose one.
--- @param items string[]
--- @param prompt string
--- @param on_choice fun(choice: string)
function M.choose(items, prompt, on_choice)
  local max = 400
  if #items == 0 then return notify("no candidates") end

  if #items > 1 then
    local query = vim.fn.input(prompt .. "> ")
    if query == "" then return end
    items = vim.fn.matchfuzzy(items, query)
    if #items == 0 then return notify("no match for '" .. query .. "'") end
    if #items > max then
      notify(("%d matches, showing %d: refine the query"):format(#items, max))
      items = vim.list_slice(items, 1, max)
    end
  end

  if #items == 1 then return on_choice(items[1]) end
  vim.ui.select(items, { prompt = prompt }, function(choice)
    if choice then on_choice(choice) end
  end)
end

local function project_root()
  return vim.fs.root(0, ".git") or vim.fn.getcwd()
end

function M.files()
  local root = project_root()
  local files = vim.fn.systemlist({
    "git", "-C", root, "ls-files", "--cached", "--others", "--exclude-standard",
  })
  if vim.v.shell_error ~= 0 or #files == 0 then
    files = vim.fn.globpath(root, "**/*", false, true)
  end

  local prefix = root .. "/"
  local candidates, seen = {}, {}
  for _, file in ipairs(files) do
    local rel = file:sub(1, #prefix) == prefix and file:sub(#prefix + 1) or file
    local full = root .. "/" .. rel
    if not seen[rel] and vim.fn.filereadable(full) == 1 then
      seen[rel] = true
      candidates[#candidates + 1] = rel
    end
  end

  M.choose(candidates, "Files", function(choice)
    vim.cmd.edit(vim.fn.fnameescape(root .. "/" .. choice))
  end)
end

--- Run a project-wide search into the quickfix list (native, navigable with ]q/[q).
--- @param pattern? string Text or regex; prompted when nil.
function M.grep(pattern)
  pattern = pattern or vim.fn.input("Grep> ")
  if pattern == "" then return end

  local items = {}
  if vim.fn.executable("rg") == 1 then
    local output = vim.fn.systemlist({
      "rg", "--vimgrep", "--smart-case", "--hidden", "--glob", "!.git",
      "--max-columns", "300", "--max-columns-preview", "-e", pattern,
    })
    for _, line in ipairs(output) do
      local file, lnum, col, text = line:match("^(.-):(%d+):(%d+):(.*)$")
      if file then
        items[#items + 1] = { filename = file, lnum = tonumber(lnum), col = tonumber(col), text = text }
      end
    end
  else
    vim.cmd("silent! vimgrep /" .. vim.fn.escape(pattern, "/\\") .. "/gj **/*")
    items = vim.fn.getqflist()
  end

  vim.fn.setqflist({}, " ", { title = "grep: " .. pattern, items = items })
  if #items == 0 then return notify("no matches for '" .. pattern .. "'") end
  vim.cmd.copen()
end

function M.buffers()
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  local labels, map = {}, {}
  for _, buffer in ipairs(buffers) do
    local label = buffer.name == "" and "[No Name]" or vim.fn.fnamemodify(buffer.name, ":~:.")
    labels[#labels + 1] = label
    map[label] = buffer.bufnr
  end
  if #labels == 0 then return notify("no buffers") end
  vim.ui.select(labels, { prompt = "Buffers" }, function(choice)
    if choice then vim.cmd.buffer(map[choice]) end
  end)
end

function M.recent()
  local files = {}
  for _, file in ipairs(vim.v.oldfiles) do
    if vim.fn.filereadable(file) == 1 then files[#files + 1] = file end
  end
  M.choose(files, "Recent", function(choice)
    vim.cmd.edit(vim.fn.fnameescape(choice))
  end)
end

function M.help()
  M.choose(vim.fn.getcompletion("", "help"), "Help", function(choice)
    vim.cmd("help " .. choice)
  end)
end

function M.keymaps()
  local labels, mapping = {}, {}
  for _, mode in ipairs({ "n", "x", "i", "o", "t" }) do
    for _, item in ipairs(vim.api.nvim_get_keymap(mode)) do
      local label = ("[%s] %s%s"):format(mode, item.lhs, item.desc and ("  " .. item.desc) or "")
      if not mapping[label] then
        mapping[label] = item.lhs
        labels[#labels + 1] = label
      end
    end
  end
  table.sort(labels)
  M.choose(labels, "Keymaps", function(choice)
    local keys = vim.api.nvim_replace_termcodes(mapping[choice], true, false, true)
    vim.api.nvim_feedkeys(keys, "m", false)
  end)
end

return M
