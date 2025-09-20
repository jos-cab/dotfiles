return {
  -- Configure blink.cmp (LazyVim's default completion engine)
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      keymap = {
        preset = "default",
      },
    },
  },

  -- Trouble configuration for better diagnostics
  {
    "folke/trouble.nvim",
    opts = {
      use_diagnostic_signs = true,
      auto_close = true,
      auto_preview = true,
    },
  },

  -- Disable alpha dashboard (we don't need a start screen)
  {
    "goolord/alpha-nvim",
    enabled = false,
  },

  -- Disable nvim-cmp since we're using blink.cmp
  {
    "hrsh7th/nvim-cmp",
    enabled = false,
  },
}