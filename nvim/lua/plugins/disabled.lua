-- Disable unnecessary plugins to reduce startup time and complexity
return {
  -- Disable plugins we don't need
  { "goolord/alpha-nvim", enabled = false },
  { "hrsh7th/nvim-cmp", enabled = false },
  { "folke/tokyonight.nvim", enabled = false }, -- We use catppuccin
  { "echasnovski/mini.starter", enabled = false },
  { "rcarriga/nvim-notify", enabled = false }, -- Use snacks.nvim notifications
  { "folke/persistence.nvim", enabled = false }, -- Don't need session persistence
  { "nvim-pack/nvim-spectre", enabled = false }, -- grug-far is better
}