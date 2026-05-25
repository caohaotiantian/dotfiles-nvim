return {
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    version = "1.*", -- use prebuilt binaries from release tags
    dependencies = { "rafamadriz/friendly-snippets", "L3MON4D3/LuaSnip" },
    opts = {
      keymap = { preset = "super-tab" }, -- <Tab> accepts/expands snippet, <S-Tab> prev, <C-Space> opens menu
      appearance = { nerd_font_variant = "mono" },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      snippets = { preset = "luasnip" },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        menu = { border = "rounded", draw = { treesitter = { "lsp" } } },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "rounded" }
        },
        ghost_text = { enabled = true },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      fuzzy = { implementation = "prefer_rust" }, -- frizbee SIMD matcher
    },
  },
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function() require("luasnip.loaders.from_vscode").lazy_load() end,
      },
    },
  },
}
