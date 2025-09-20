return {
  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Python
        pyright = {},
        -- Lua
        lua_ls = {},
        -- Rust
        rust_analyzer = {},
        -- Go
        gopls = {},
        -- C/C++
        clangd = {},
        -- JSON
        jsonls = {},
      },
    },
  },
}