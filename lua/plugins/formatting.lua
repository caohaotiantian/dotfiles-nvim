return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo", "FormatDisable", "FormatEnable" },
    keys = { {
      "<leader>cF",
      function() require("conform").format({ async = true, lsp_fallback = true }) end,
      mode = { "n", "v" },
      desc = "Format buffer"
    } },
    init = function()
      vim.api.nvim_create_user_command("FormatDisable", function(a)
        if a.bang then vim.b.disable_autoformat = true else vim.g.disable_autoformat = true end
      end, { bang = true, desc = "Disable autoformat-on-save (! = buffer only)" })
      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = "Re-enable autoformat-on-save" })
    end,
    opts = {
      formatters_by_ft = {
        lua             = { "stylua" },
        python          = { "ruff_format", "ruff_organize_imports" },
        javascript      = { "prettierd", "prettier", stop_after_first = true },
        typescript      = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json            = { "prettierd", "prettier", stop_after_first = true },
        yaml            = { "prettierd", "prettier", stop_after_first = true },
        markdown        = { "prettierd", "prettier", stop_after_first = true },
        html            = { "prettierd", "prettier", stop_after_first = true },
        css             = { "prettierd", "prettier", stop_after_first = true },
        rust            = { "rustfmt", lsp_format = "fallback" },
        c               = { "clang-format" },
        cpp             = { "clang-format" },
        sh              = { "shfmt" },
        bash            = { "shfmt" },
        toml            = { "taplo" },
      },
      format_on_save = function(bufnr)
        if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then return end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
      formatters = {
        shfmt = { prepend_args = { "-i", "2", "-ci" } },
        ["clang-format"] = { prepend_args = { "--style=file", "--fallback-style=LLVM" } },
      },
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "stylua", "prettierd", "shfmt", "clang-format", "taplo", "shellcheck",
        "debugpy", "codelldb", "js-debug-adapter",
      },
      run_on_start = true,
      start_delay = 3000,    -- avoid hammering network during dashboard render
      debounce_hours = 24,   -- skip the check if we ran in the last 24h
    },
  },
}
