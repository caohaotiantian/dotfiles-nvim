return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    build = ":MasonUpdate",
    opts = { ui = { border = "rounded" } },
  },

  -- Proper Neovim Lua dev: types + completion for vim.* APIs and plugin specs.
  -- Replaces hand-rolled `library = nvim_get_runtime_file("", true)` in lua_ls.
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      automatic_enable = true,       -- v2.x default: auto vim.lsp.enable()
      ensure_installed = {
        "basedpyright", "ruff",      -- Python
        "vtsls",                     -- TS/JS
        "clangd",                    -- C/C++
        "bashls",                    -- Bash
        "lua_ls",                    -- Lua
        "jsonls", "yamlls", "taplo", -- json/yaml/toml
        -- rust_analyzer is intentionally absent — rustaceanvim manages it.
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- LspAttach: buffer-local keymaps + features for every attached server.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end
          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = "LSP: " .. desc })
          end
          -- Neovim 0.11+ already maps K, grn, gra, grr, gri, grt, gO, <C-S>.
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format")

          if client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
          end

          if client:supports_method("textDocument/documentHighlight") then
            local hl = vim.api.nvim_create_augroup("user-lsp-hl-" .. args.buf, { clear = true })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" },
              { buffer = args.buf, group = hl, callback = vim.lsp.buf.document_highlight })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" },
              { buffer = args.buf, group = hl, callback = vim.lsp.buf.clear_references })
            -- Tear down the per-buffer augroup when the LSP detaches or buffer goes away.
            vim.api.nvim_create_autocmd({ "LspDetach", "BufWipeout" }, {
              buffer = args.buf,
              once = true,
              callback = function()
                pcall(vim.api.nvim_del_augroup_by_id, hl)
              end,
            })
          end
        end,
      })

      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
              typeCheckingMode = "standard",
            },
            disableOrganizeImports = true, -- Ruff handles imports
          }
        },
      })

      vim.lsp.config("ruff", {
        init_options = { settings = { logLevel = "error" } },
        on_attach = function(client) -- defer hover to basedpyright
          client.server_capabilities.hoverProvider = false
        end,
      })

      vim.lsp.config("vtsls", {
        settings = {
          typescript = {
            inlayHints = {
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              enumMemberValues = { enabled = true },
            }
          }
        },
      })

      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
        },
      })

      -- Library is supplied by lazydev.nvim; just keep runtime + diagnostics here.
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false },
            diagnostics = { globals = { "vim" } },
          }
        },
      })
    end,
  },
}
