return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui",           dependencies = { "nvim-neotest/nvim-nio" } },
      { "theHamsta/nvim-dap-virtual-text" },
      { "jay-babu/mason-nvim-dap.nvim",   opts = { handlers = {}, ensure_installed = {} } },
      { "mfussenegger/nvim-dap-python" },
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end,          desc = "Continue" },
      { "<leader>di", function() require("dap").step_into() end,         desc = "Step into" },
      { "<leader>do", function() require("dap").step_over() end,         desc = "Step over" },
      { "<leader>dO", function() require("dap").step_out() end,          desc = "Step out" },
      { "<leader>du", function() require("dapui").toggle() end,          desc = "Toggle UI" },
      { "<leader>dx", function() require("dap").terminate() end,         desc = "Terminate" },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup(); require("nvim-dap-virtual-text").setup({})

      -- Auto-open / close UI alongside debug sessions.
      dap.listeners.before.attach.dapui_config           = function() dapui.open() end
      dap.listeners.before.launch.dapui_config           = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config     = function() dapui.close() end

      local mason                                        = vim.fn.stdpath("data") .. "/mason/packages"
      require("dap-python").setup(mason .. "/debugpy/venv/bin/python")

      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = { command = mason .. "/codelldb/codelldb", args = { "--port", "${port}" } },
      }
      for _, ft in ipairs({ "c", "cpp" }) do
        dap.configurations[ft] = { {
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = function() return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file") end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        } }
      end

      -- vscode-js-debug (Mason package: js-debug-adapter)
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = { command = "js-debug-adapter", args = { "${port}" } },
      }
      for _, ft in ipairs({ "javascript", "typescript" }) do
        dap.configurations[ft] = { {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
        } }
      end
    end,
  },
}
