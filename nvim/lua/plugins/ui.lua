return {
  -- Configure blink.cmp keybindings (sources configured in codeium.lua)
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "snippet_forward", "accept", "select_next", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
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