return {
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
  {
    "folke/trouble.nvim",
    opts = {
      use_diagnostic_signs = true,
      auto_close = true,
      auto_preview = true,
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[

                                       
             ██                       ██
            ████                     ████
           ██████                   ██████
          ████████                 ████████
         ██████████               ██████████
        ████████████             ████████████
       ██████████████           ██████████████
      ████████████████         ████████████████
     ██████████████████       ██████████████████
    ████████████████████     ████████████████████
   ██████████████████████   ██████████████████████
  ████████████████████████ ████████████████████████
 ████████████████████████████████████████████████████
╾────────────────────────────────────────────────────────╼
                 󰘧  N E O V I M  󰘧
           󰆍  edit  ·  explore  ·  create 󰆍

]],
        },
        sections = {
          { section = "header", padding = 2 },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
    },
  },
}
