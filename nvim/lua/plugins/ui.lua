return {
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

  -- Disable alpha dashboard to avoid conflicts
  {
    "goolord/alpha-nvim",
    enabled = false,
  },
}