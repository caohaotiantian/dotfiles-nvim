# dotfiles-nvim

Personal Neovim configuration with **no plugin manager and no third-party plugins**.
Everything here uses features that ship with Neovim itself. Verified on Neovim 0.12.6
(macOS, arm64); the config needs **0.12+** because it uses `completeopt+=fuzzy`,
`completeopt+=popup`, and `vim.lsp.config` / `vim.lsp.enable`.

## Requirements

| Tool | Purpose | Without it |
|---|---|---|
| Neovim 0.12+ | everything | — |
| `git` | hunk signs, blame, diff view, file list for the picker | picker uses `globpath`, git features report "not inside a repository" |
| `rg` (ripgrep) | `<leader>fg` / `<leader>fw` search | falls back to `:vimgrep` |
| LSP servers on `$PATH` | completion, diagnostics, format on save | no LSP; syntax and editing still work |
| tree-sitter parsers in `~/.local/share/nvim/site/parser` | treesitter highlighting and folding | regex syntax highlighting |

Server executables are looked up in `~/.local/bin`, then `~/.local/share/nvim/mason/bin`,
then the regular `$PATH` (see `lua/config/lsp.lua`). A server is enabled only when its
executable exists.

Two servers needed a manual install on this machine:

- `uv tool install basedpyright` — the Mason copy of basedpyright has a dangling
  `python3.14` symlink and cannot start.
- `rustup component add rust-analyzer` — the stable toolchain had no rust-analyzer
  component, so the rustup proxy exited with code 1.

## Layout

```
init.lua                  -- leader keys, then loads the modules below
lua/config/
  options.lua             -- vim.opt, diagnostics, netrw, colorscheme
  autocmds.lua            -- yank highlight, last cursor, auto-mkdir, prose/terminal settings
  keymaps.lua             -- global mappings
  statusline.lua          -- statusline built from the `statusline` option
  treesitter.lua          -- vim.treesitter highlighting + folding per filetype
  lsp.lua                 -- server activation, LspAttach maps, format on save
  git.lua                 -- hunk signs, blame float, HEAD diff view
  picker.lua              -- native fuzzy file/buffer/grep pickers
lsp/                      -- one vim.lsp.config table per server
after/ftplugin/           -- python.lua, rust.lua
```

Total: about 1000 lines of Lua, comments included, and 10 server config files. Startup
measured with `--startuptime`: **20–25 ms**, zero plugin scripts loaded.

## What replaced the plugins

| Old plugin | Native mechanism now |
|---|---|
| lazy.nvim | nothing to manage; `lsp/*.lua` and `after/ftplugin/*.lua` are plain runtime files |
| nvim-lspconfig + mason | `vim.lsp.config` reads `lsp/<name>.lua`; `vim.lsp.enable` starts servers |
| blink.cmp + LuaSnip | `vim.lsp.completion.enable(…, { autotrigger = true })` plus `vim.snippet` |
| nvim-treesitter | `vim.treesitter.start()` with parsers already installed under `site/parser` |
| conform.nvim | `vim.lsp.buf.format()` on `BufWritePre` when the client supports formatting |
| nvim-lint | LSP diagnostics: ruff for Python, shellcheck through bashls for shell |
| gitsigns | `git diff --unified=0` parsed into `sign_text` extmarks |
| diffview | `:diffthis` on a split containing `git show HEAD:<file>` |
| lualine | `statusline` option with `v:lua` callbacks |
| bufferline | `:bnext` / `:bprevious` on `<S-h>` / `<S-l>`, plus the buffer picker |
| which-key | mapping `desc` text, shown by `<leader>fk` and `:map` |
| snacks picker / fzf-lua | `config.picker` (git ls-files + `matchfuzzy` + `vim.ui.select`) |
| snacks explorer / oil / netrw replacement | netrw, which ships with Neovim |
| flash.nvim | native `f` / `t` / `;` / `,` and `vim.fn.matchfuzzy` in the pickers |
| mini.ai / mini.surround / mini.pairs | none; native text objects and `:h i_CTRL-V` |
| nvim-dap + dap-ui | removed; use a terminal (`<leader>tt`) |
| tokyonight | `habamax`, shipped in `$VIMRUNTIME/colors` |

## Keymaps

Leader is `<space>`.

| Keys | Action |
|---|---|
| `<leader><space>`, `<leader>ff` | find files (fuzzy, project-scoped) |
| `<leader>fg`, `<leader>fw` | grep prompt, grep word under cursor |
| `<leader>fb`, `<leader>fr` | buffers, recently opened files |
| `<leader>fh`, `<leader>fk` | help tags, keymaps |
| `<leader>e`, `-` | file explorer sidebar (`:Lexplore`, 30% width), explore current directory |
| `<C-s>` | write file (normal, insert, visual) |
| `<leader>q`, `<leader>Q` | quit window, force quit all |
| `<S-h>`, `<S-l>` | previous / next buffer |
| `<leader>bd`, `<leader>bo` | delete buffer, delete other buffers |
| `<C-hjkl>`, `<leader>wv/ws/wq/wo/w=` | window navigation, split, close, equalize |
| `]d`, `[d` | next / previous diagnostic (floating message) |
| `<leader>cd`, `<leader>xx`, `<leader>xl` | line diagnostics, all diagnostics to quickfix/loclist |
| `]q`, `[q`, `<leader>xq`, `<leader>xQ` | quickfix next/previous, open, close |
| `]h`, `[h` | next / previous git hunk |
| `<leader>gb`, `<leader>gd`, `<leader>gs` | blame line, diff against HEAD, `git status` in a terminal |
| `<leader>tt`, `<Esc><Esc>` | terminal (reuses an existing one), leave terminal mode |
| `<leader>uw/un/ul/us/ud` | toggle wrap, numbers, list chars, spell, inline diagnostics |
| `gd`, `gD`, `gi` | definition, declaration, implementation (buffer-local, LSP) |
| `<leader>cr`, `<leader>ca`, `<leader>cf`, `<leader>ci` | rename, code action, format, inlay hints |
| `<C-y>`, `<C-n>`, `<C-p>` | accept, next, previous completion item |

`:FormatDisable`, `:FormatDisable!`, `:FormatEnable` switch format on save globally or
for the current buffer.

## Behaviour notes

**Completion.** `vim.lsp.completion` triggers on the server's own trigger characters.
`lua/config/lsp.lua` extends that list with letters, digits, and `_`, so the menu also
opens while you type a word. Accepting an item applies its side effects, including
snippet expansion through core `vim.snippet`.

**Formatting.** Format on save runs the first attached client that supports
`textDocument/formatting`: ruff or lua_ls or vtsls or clangd or rust-analyzer. A save
takes up to `timeout_ms = 2000`. Files without a formatting client are written
unformatted.

**Treesitter.** A filetype gets treesitter only when a parser exists on the runtimepath.
Other filetypes keep regex syntax highlighting. Folding (`foldexpr`) switches to
treesitter for parsed buffers.

**Git signs** compare the file on disk with `HEAD`. They do not show the difference
between the working tree and the index, and staging is manual (`git add -p`).

**Picker.** Two prompts: type a query, then choose from the fuzzy matches. The candidate
list is capped at 400 entries. `<C-w>` and `<C-u>` work in the query prompt.

## Adding things

- **New LSP server**: create `lsp/<name>.lua` with `cmd`, `filetypes`, `root_markers`,
  then add the name to the `servers` list in `lua/config/lsp.lua`. Install the executable
  with your package manager (`uv tool install`, Homebrew, `npm -g`) or with `mason.nvim`
  in a different profile.
- **New treesitter parser**: put `parser/<lang>.so` and `queries/<lang>/` under
  `~/.local/share/nvim/site`. The config picks it up on the next `FileType` event.
- **New filetype tweak**: add `after/ftplugin/<ft>.lua`.
- **New mapping**: add it to `lua/config/keymaps.lua` with a `desc` so it appears in
  `<leader>fk`.

## Removed on purpose

Debugging UI (nvim-dap), git staging UI, dashboard, notification centre, file icons,
floating terminals, snippet collections beyond core snippets, and the plugin manager.
The replacements are command-line tools or core features; run them from `<leader>tt`
when a graphical tool is missing.

## Cleanup after the migration

The old plugin data is separate from this repository. Remove it when you no longer want
the fallback:

```sh
rm -rf ~/.local/share/nvim/lazy ~/.local/share/nvim/snacks
```

Keep `~/.local/share/nvim/site`: it holds the tree-sitter parsers and queries this config
uses. Keep `~/.local/share/nvim/mason/bin` only for servers that still work; the
`basedpyright` venv installed by Mason is broken on this machine (it refers to a missing
`python3.14`), so `basedpyright` now comes from `uv tool install basedpyright`.

## License

MIT.
