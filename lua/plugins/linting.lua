return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("lint").linters_by_ft = { sh = { "shellcheck" }, bash = { "shellcheck" } }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" },
        { callback = function() require("lint").try_lint() end })
    end,
  },
}
