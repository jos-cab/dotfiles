-- Permanently remove unwanted plugins
return {
  -- Remove start screens completely
  { "goolord/alpha-nvim", enabled = false },
  { "nvim-mini/mini.starter", enabled = false },
  
  -- Remove old completion system (we use blink.cmp)
  { "hrsh7th/nvim-cmp", enabled = false },
  
  -- Remove unused themes
  { "folke/tokyonight.nvim", enabled = false },
  
  -- Remove markdown plugins I added (you don't want them)
  { "iamcco/markdown-preview.nvim", enabled = false },
  { "plasticboy/vim-markdown", enabled = false },
  
  -- Remove other potentially unwanted plugins
  { "rcarriga/nvim-notify", enabled = false }, -- Use snacks.nvim notifications instead
  { "nvim-pack/nvim-spectre", enabled = false }, -- Use grug-far instead
}