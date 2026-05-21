return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "tokyonight",
        globalstatus = true,
        section_separators = "",
        component_separators = ""
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = { diagnostics = "nvim_lsp", always_show_bufferline = false } },
    keys = {
      { "<leader>1", "<cmd>BufferLineGoToBuffer 1<cr>", desc = "Buffer 1" },
      { "<leader>2", "<cmd>BufferLineGoToBuffer 2<cr>", desc = "Buffer 2" },
      { "<leader>3", "<cmd>BufferLineGoToBuffer 3<cr>", desc = "Buffer 3" },
      { "<leader>4", "<cmd>BufferLineGoToBuffer 4<cr>", desc = "Buffer 4" },
      { "<leader>5", "<cmd>BufferLineGoToBuffer 5<cr>", desc = "Buffer 5" },
      { "<leader>6", "<cmd>BufferLineGoToBuffer 6<cr>", desc = "Buffer 6" },
      { "<leader>7", "<cmd>BufferLineGoToBuffer 7<cr>", desc = "Buffer 7" },
      { "<leader>8", "<cmd>BufferLineGoToBuffer 8<cr>", desc = "Buffer 8" },
      { "<leader>9", "<cmd>BufferLineGoToBuffer 9<cr>", desc = "Buffer 9" },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>f", group = "find" }, { "<leader>g", group = "git" },
        { "<leader>c", group = "code" }, { "<leader>x", group = "diagnostics" },
        { "<leader>b", group = "buffer" }, { "<leader>w", group = "window" },
        { "<leader>t", group = "terminal" }, { "<leader>d", group = "debug" },
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPost",
    opts = { indent = { char = "│" }, scope = { enabled = true } },
  },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      explorer = { enabled = true, replace_netrw = true },
      input = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      picker = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      lazygit = { enabled = true },
    },
    keys = {
      { "<leader><space>", function() Snacks.picker.smart() end,         desc = "Files (smart)" },
      { "<leader>ff",      function() Snacks.picker.files() end,         desc = "Find files" },
      { "<leader>fg",      function() Snacks.picker.grep() end,          desc = "Live grep" },
      { "<leader>fw",      function() Snacks.picker.grep_word() end,     desc = "Grep word", mode = { "n", "v" } },
      { "<leader>fb",      function() Snacks.picker.buffers() end,       desc = "Buffers" },
      { "<leader>fr",      function() Snacks.picker.recent() end,        desc = "Recent" },
      { "<leader>fh",      function() Snacks.picker.help() end,          desc = "Help" },
      { "<leader>fk",      function() Snacks.picker.keymaps() end,       desc = "Keymaps" },
      { "<leader>cs",      function() Snacks.picker.lsp_symbols() end,   desc = "LSP symbols" },
      { "<leader>e",       function() Snacks.explorer() end,             desc = "Explorer" },
      { "<leader>gg",      function() Snacks.lazygit() end,              desc = "Lazygit" },
      { "<leader>gb",      function() Snacks.picker.git_branches() end,  desc = "Git branches" },
      { "<leader>gl",      function() Snacks.picker.git_log() end,       desc = "Git log" },
      { "<leader>tt",      function() Snacks.terminal() end,             desc = "Terminal" },
      { "<leader>n",       function() Snacks.picker.notifications() end, desc = "Notifications" },
    },
  },

  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { default_file_explorer = false, view_options = { show_hidden = true } },
    keys = { { "-", "<cmd>Oil<cr>", desc = "Parent dir (oil)" } },
  },

  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
}
