return {
  -- Enhanced telescope configuration
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      -- Override default find files to use better settings
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
      -- Add a keymap to browse plugin files
      {
        "<leader>fp",
        function()
          require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root })
        end,
        desc = "Find Plugin File",
      },
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { 
          prompt_position = "top",
          width = 0.9,
          height = 0.8,
        },
        sorting_strategy = "ascending",
        winblend = 0,
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          "target/",
          "build/",
          "dist/",
        },
      },
    },
  },
}