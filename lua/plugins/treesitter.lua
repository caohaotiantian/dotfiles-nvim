-- 2026 setup: NEW community fork at neovim-treesitter/nvim-treesitter.
-- The old nvim-treesitter/nvim-treesitter was archived April 3, 2026.
-- The rewrite does NOT support lazy-loading and has NO ensure_installed field.
-- Requires tree-sitter CLI 0.26.1+ (from your distro/Homebrew, NOT npm) and a C compiler.

local parsers = {
  "python", "typescript", "javascript", "tsx",
  "rust", "c", "cpp", "bash",
  "lua", "vim", "vimdoc", "query",
  "markdown", "markdown_inline",
  "json", "yaml", "toml", "regex",
  "gitcommit", "gitignore", "diff", "dockerfile",
}

return {
  {
    "neovim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim-treesitter/treesitter-parser-registry",
    },
    config = function()
      local nts = require("nvim-treesitter")
      nts.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })

      -- Idempotent install: only install parsers not already present.
      local have = require("nvim-treesitter.config").get_installed() or {}
      local missing = vim.iter(parsers)
          :filter(function(p) return not vim.tbl_contains(have, p) end)
          :totable()
      if #missing > 0 then nts.install(missing) end

      vim.api.nvim_create_autocmd("PackChanged", {
        callback = function(ev)
          if ev.data and ev.data.spec and ev.data.spec.name == "nvim-treesitter" then
            vim.cmd("TSUpdate")
          end
        end,
      })

      -- Enable highlighting + folds + indent per filetype (NOT auto-enabled in the rewrite).
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if lang and pcall(vim.treesitter.start, args.buf, lang) then
            vim.wo[0][0].foldexpr        = "v:lua.vim.treesitter.foldexpr()"
            vim.wo[0][0].foldmethod      = "expr"
            vim.bo[args.buf].indentexpr  = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
