return {
  -- LSP configuration - only essential servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Lua (for nvim config)
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
        -- Python
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
              },
            },
          },
        },
        -- JSON
        jsonls = {},
        -- Bash
        bashls = {},
      },
    },
  },

  -- Configure diagnostics
  {
    "neovim/nvim-lspconfig",
    opts = function()
      -- Add custom keymaps
    end,
  },
}
