return {
  -- Mason tool installer - only essential tools
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- Lua
        "stylua",
        -- Shell
        "shellcheck",
        "shfmt",
        -- Python
        "black",
        "ruff",
        -- JavaScript/TypeScript
        "prettier",
        -- JSON/YAML
        "jq",
      },
    },
  },

  -- Configure conform for formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black", "ruff_format" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        sh = { "shfmt" },
      },
      -- format_on_save is handled by LazyVim automatically
    },
  },
}