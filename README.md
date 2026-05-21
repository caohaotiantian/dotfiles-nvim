# dotfiles-nvim

My personal [Neovim](https://neovim.io/) configuration. Targets **Neovim 0.11+** and the
modern Lua API (`vim.lsp.config`, `vim.diagnostic.jump`, the new `nvim-treesitter`
community fork).

## Highlights

- **Plugin manager:** [lazy.nvim](https://github.com/folke/lazy.nvim) (lazy-by-default)
- **LSP:** `vim.lsp.config` + `mason-lspconfig` (basedpyright/ruff, vtsls, clangd, lua_ls, bashls, jsonls/yamlls/taplo)
- **Completion:** [blink.cmp](https://github.com/saghen/blink.cmp) with the Rust frizbee matcher + LuaSnip
- **Treesitter:** [`neovim-treesitter/nvim-treesitter`](https://github.com/neovim-treesitter/nvim-treesitter) (the 2026 community rewrite)
- **Formatting:** [conform.nvim](https://github.com/stevearc/conform.nvim) (`:FormatDisable[!]` / `:FormatEnable`)
- **Linting:** [nvim-lint](https://github.com/mfussenegger/nvim-lint)
- **Git:** gitsigns + diffview + lazygit (via snacks)
- **UI:** tokyonight, lualine, bufferline, snacks (dashboard / picker / explorer / notifier / terminal), which-key
- **Debugging:** nvim-dap + dap-ui (Python via debugpy, C/C++/Rust via codelldb, JS/TS via vscode-js-debug)
- **Rust:** [rustaceanvim](https://github.com/mrcjkb/rustaceanvim) (owns `rust-analyzer` — do **not** also enable it in mason-lspconfig)
- **Lua dev:** [lazydev.nvim](https://github.com/folke/lazydev.nvim) for full Neovim API typings

## Install

```sh
git clone https://github.com/caohaotiantian/dotfiles-nvim ~/.config/nvim
nvim --headless "+Lazy! sync" +qa
```

External tools the config expects on `$PATH`:

- `git`, a C compiler (for treesitter parsers)
- `tree-sitter` CLI (`brew install tree-sitter` — 0.26.1+; **not** the npm package)
- Node.js (for vtsls / prettierd / js-debug-adapter)
- Rust toolchain + `rustup component add rust-analyzer` (or let Mason install)

The rest (formatters, linters, debuggers) is auto-installed by Mason on first launch.

## Layout

```
init.lua                  -- entrypoint: loads options → keymaps → autocmds → lazy
lua/
  config/
    options.lua           -- vim.opt, diagnostic.config
    keymaps.lua           -- non-plugin keymaps
    autocmds.lua          -- yank-highlight, last-cursor, auto-mkdir, close-with-q
    lazy.lua              -- lazy.nvim bootstrap
  plugins/
    colorscheme.lua       -- tokyonight
    completion.lua        -- blink.cmp + LuaSnip
    dap.lua               -- nvim-dap + adapters
    editing.lua           -- flash, mini.*, trouble, highlight-colors
    formatting.lua        -- conform + mason-tool-installer
    git.lua               -- gitsigns + diffview
    lang-rust.lua         -- rustaceanvim + crates.nvim
    linting.lua           -- nvim-lint
    lsp.lua               -- mason, mason-lspconfig, lspconfig, lazydev
    treesitter.lua        -- nvim-treesitter (rewrite)
    ui.lua                -- lualine, bufferline, which-key, indent-blankline, snacks, oil, todo-comments
after/
  ftplugin/
    python.lua            -- 4-space indent, 88-col ruler
    rust.lua              -- 4-space indent, 100-col ruler
```

## Leader-key cheatsheet

| Prefix       | Group       | Examples                                      |
|--------------|-------------|-----------------------------------------------|
| `<leader>f`  | find        | `ff` files · `fg` grep · `fw` grep word · `fb` buffers · `fr` recent · `fh` help · `fk` keymaps |
| `<leader>g`  | git         | `gg` lazygit · `gd` diffview · `gh` history · `gb` branches · `gl` log · `ghs/ghr/ghp/ghb` hunks |
| `<leader>c`  | code        | `cf` LSP format · `cF` conform format · `cd` line diagnostics · `cs` LSP symbols |
| `<leader>x`  | diagnostics | `xx` all · `xd` buffer · `xs` symbols · `xq` quickfix |
| `<leader>b`  | buffer      | `bd` delete buffer; `<S-h>`/`<S-l>` prev/next |
| `<leader>w`  | window      | `wv` vsplit · `ws` split · `wo` only · `wq` close · `w=` equalize |
| `<leader>d`  | debug       | `db` breakpoint · `dc` continue · `di/do/dO` step · `du` UI · `dx` terminate |
| `<leader>t`  | terminal    | `tt` snacks terminal                          |
| `<leader>1`–`9` | bufferline | jump to buffer N                           |
| `-`          | -           | open parent dir in `oil`                      |
| `s` / `S`    | -           | flash jump / flash treesitter                 |

## License

MIT.
