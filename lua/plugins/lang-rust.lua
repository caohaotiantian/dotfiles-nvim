-- rustaceanvim is THE 2026 Rust setup. It configures rust-analyzer itself, so
-- do NOT also enable `rust_analyzer` in mason-lspconfig's ensure_installed.
return {
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
    ft = { "rust" },
    config = function()
      local mason_pkg    = vim.fn.stdpath("data") .. "/mason/packages/codelldb"
      local codelldb     = mason_pkg .. "/codelldb"
      local liblldb      = mason_pkg .. "/extension/lldb/lib/liblldb."
          .. (vim.fn.has("mac") == 1 and "dylib" or "so")

      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              checkOnSave = true,
              check = { command = "clippy" },
              procMacro = { enable = true },
            }
          }
        },
        dap = { adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, liblldb) },
      }
    end,
  },

  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = { crates = { enabled = true } },
      lsp = { enabled = true, actions = true, completion = true, hover = true },
    },
  },
}
