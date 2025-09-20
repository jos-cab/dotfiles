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
}