return {
  -- Mason tool installer
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- Lua
        "stylua",
        -- Shell
        "shellcheck",
        "shfmt",
        -- Python
        "black",
        "isort",
        "flake8",
        -- JavaScript/TypeScript
        "prettier",
        "eslint_d",
        -- Go
        "gofumpt",
        "goimports",
        -- Rust
        "rustfmt",
        -- C/C++
        "clang-format",
      },
    },
  },
}