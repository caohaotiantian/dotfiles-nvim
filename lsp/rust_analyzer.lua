return {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json" },
  -- Only start inside a real project: rust-analyzer exits with an error when it
  -- gets no workspace root (for example on a lone .rs file in /tmp).
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, { "Cargo.toml", "rust-project.json" })
    if root then on_dir(root) end
  end,
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      check = { command = "clippy", extraArgs = { "--profile", "test" } },
      checkOnSave = true,
      procMacro = { enable = true },
      inlayHints = {
        closureReturnTypeHints = { enable = "always" },
        lifetimeElisionHints = { enable = "skip_trivial" },
      },
    },
  },
}
