-- Treesitter highlighting and folding with the parsers already installed under
-- ~/.local/share/nvim/site/parser (installed externally; Neovim core loads them).
local augroup = vim.api.nvim_create_augroup("user_treesitter", { clear = true })

-- Filetypes whose parser has a different language name.
local aliases = {
  sh = "bash",
  typescriptreact = "tsx",
  javascriptreact = "javascript",
  jsonc = "json",
}
for filetype, language in pairs(aliases) do
  vim.treesitter.language.register(language, filetype)
end

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  callback = function(args)
    local language = vim.treesitter.language.get_lang(args.match) or args.match
    -- pcall: filetypes without an installed parser fall back to regex syntax.
    if not pcall(vim.treesitter.language.add, language) then return end
    if not pcall(vim.treesitter.start, args.buf, language) then return end

    vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
      group = augroup,
      buffer = args.buf,
      callback = function()
        vim.wo[0][0].foldmethod = "expr"
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo[0][0].foldlevel = 99
      end,
    })
  end,
})
