return {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml" },
  root_markers = { ".git" },
  init_options = { provideFormatter = true },
  settings = {
    yaml = {
      schemaStore = { enable = true },
      validate = true,
      format = { enable = true },
    },
  },
}
