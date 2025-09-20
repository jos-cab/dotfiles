return {
  -- Use mini.starter instead of alpha
  { import = "lazyvim.plugins.extras.ui.mini-starter" },

  -- Enhanced completion with emoji support
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    opts = function(_, opts)
      table.insert(opts.sources, { name = "emoji" })
    end,
  },

  -- Trouble configuration
  {
    "folke/trouble.nvim",
    opts = { use_diagnostic_signs = true },
  },
}