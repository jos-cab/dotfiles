return {
  -- Enhanced telescope configuration
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
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