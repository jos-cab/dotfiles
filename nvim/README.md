# Neovim Configuration

A modern Neovim configuration based on [LazyVim](https://github.com/LazyVim/LazyVim) with Catppuccin Mocha theme.

## Features

-   **Theme**: Catppuccin Mocha (matches kitty and ranger themes)
-   **Plugin Manager**: Lazy.nvim for fast startup and lazy loading
-   **LSP**: Pre-configured language servers for multiple languages
-   **Completion**: Enhanced completion with emoji support
-   **Telescope**: Better search and file finding
-   **Treesitter**: Syntax highlighting for many languages
-   **Tools**: Auto-installed formatters and linters via Mason

## Included Languages

-   Python (pyright, black, isort, flake8)
-   TypeScript/JavaScript (tsserver, prettier, eslint_d)
-   Lua (lua_ls, stylua)
-   Rust (rust_analyzer, rustfmt)
-   Go (gopls, gofumpt, goimports)
-   C/C++ (clangd, clang-format)
-   Shell (shellcheck, shfmt)

## Installation

This configuration is automatically installed via the dotfiles install script.

## Customization

Add your custom plugins and configurations in the `lua/plugins/` directory.
Each file in this directory will be automatically loaded by LazyVim.
