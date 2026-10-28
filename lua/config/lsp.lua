-- Native LSP: server configs live in lsp/*.lua, activated by `vim.lsp.enable`.
-- No plugin manager: servers are found on $PATH (Mason's bin dir is added below).
local M = {}

-- Servers installed by `uv tool` / `pipx` live in ~/.local/bin; Mason's bin dir keeps
-- servers installed earlier usable without the Mason plugin. Prepended in reverse so
-- the first entry ends up in front.
local extra_bins = {
  vim.fn.expand("~/.local/bin"),
  vim.fn.stdpath("data") .. "/mason/bin",
}
for index = #extra_bins, 1, -1 do
  local dir = extra_bins[index]
  if vim.uv.fs_stat(dir) and not (vim.env.PATH or ""):find(dir, 1, true) then
    vim.env.PATH = dir .. ":" .. (vim.env.PATH or "")
  end
end

local servers = {
  "basedpyright",
  "ruff",
  "vtsls",
  "clangd",
  "lua_ls",
  "bashls",
  "jsonls",
  "yamlls",
  "taplo",
  "rust_analyzer",
}

for _, name in ipairs(servers) do
  local config = vim.lsp.config[name]
  local cmd = config and config.cmd
  local executable = type(cmd) == "table" and cmd[1] or cmd
  if type(executable) == "string" and vim.fn.executable(executable) == 1 then
    vim.lsp.enable(name)
  end
end

-- Format-on-save switches (same interface as the old conform setup).
vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, { bang = true, desc = "Disable format on save (bang: current buffer only)" })

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, { desc = "Enable format on save" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    local buf = args.buf

    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = "LSP: " .. desc })
    end

    -- Neovim already maps grn/gra/grr/gri/grt/gO and K in 0.11+.
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("gi", vim.lsp.buf.implementation, "Go to implementation")
    map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
    map("<leader>ci", function()
      local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
      vim.lsp.inlay_hint.enable(not enabled, { bufnr = buf })
    end, "Toggle inlay hints")

    -- ruff provides hover only for noqa directives; prefer basedpyright's.
    if client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end

    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })
    end

    if client:supports_method("textDocument/documentHighlight") then
      local highlight = vim.api.nvim_create_augroup("user_lsp_highlight_" .. buf, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = highlight,
        buffer = buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = highlight,
        buffer = buf,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd({ "LspDetach", "BufWipeout" }, {
        group = highlight,
        buffer = buf,
        once = true,
        callback = function() pcall(vim.api.nvim_del_augroup_by_id, highlight) end,
      })
    end

    -- Format on save, using the first attached client that can format.
    if client:supports_method("textDocument/formatting") then
      local format_group = vim.api.nvim_create_augroup("user_lsp_format_" .. buf, { clear = true })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = format_group,
        buffer = buf,
        callback = function()
          if vim.b[buf].disable_autoformat or vim.g.disable_autoformat then return end
          vim.lsp.buf.format({ bufnr = buf, timeout_ms = 2000 })
        end,
      })
      vim.api.nvim_create_autocmd("BufWipeout", {
        group = format_group,
        buffer = buf,
        once = true,
        callback = function() pcall(vim.api.nvim_del_augroup_by_id, format_group) end,
      })
    end

    -- Native insert-mode completion. Extending the trigger characters makes the
    -- menu open while typing a word, not only after the server's own triggers.
    local completion = client.server_capabilities.completionProvider
    if completion then
      completion.triggerCharacters = completion.triggerCharacters or {}
      local known = {}
      for _, char in ipairs(completion.triggerCharacters) do known[char] = true end
      for char in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"):gmatch(".") do
        if not known[char] then completion.triggerCharacters[#completion.triggerCharacters + 1] = char end
      end
      vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
    end
  end,
})

return M
