-- Disable only the LazyVim default plugins that are actually installed but we don't want
return {
  -- Themes we don't use (we use catppuccin)
  { "folke/tokyonight.nvim", enabled = false },
  
  -- Start screens (disable both)
  { "goolord/alpha-nvim", enabled = false },
  { "nvim-mini/mini.starter", enabled = false },
  
  -- Old completion system (we use blink.cmp)
  { "hrsh7th/nvim-cmp", enabled = false },
  
  -- Session management (if you don't use sessions)
  { "folke/persistence.nvim", enabled = false },
}