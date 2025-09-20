return {
  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Python
        pyright = {},
        -- TypeScript/JavaScript
        tsserver = {},
        -- Lua
        lua_ls = {},
        -- Rust
        rust_analyzer = {},
        -- Go
        gopls = {},
        -- C/C++
        clangd = {},
      },
    },
  },

  -- Import language-specific extras
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lang.json" },
}