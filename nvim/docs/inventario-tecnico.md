# Inventario técnico

## Archivos declarativos

| Archivo | Función |
|---|---|
| `init.lua` | Entry point |
| `lua/config/lazy.lua` | Bootstrap, LazyVim, imports y runtime plugins |
| `lua/config/options.lua` | Opciones globales; sin cambios locales |
| `lua/config/keymaps.lua` | Keymaps; sin cambios locales |
| `lua/config/autocmds.lua` | Autocmds; sin cambios locales |
| `lua/plugins/colorscheme.lua` | Catppuccin |
| `lua/plugins/disabled.lua` | Plugins deshabilitados |
| `lua/plugins/lsp.lua` | Servidores LSP |
| `lua/plugins/telescope.lua` | Búsqueda y keymap `<leader>fp` |
| `lua/plugins/tools.lua` | Mason y Conform |
| `lua/plugins/treesitter.lua` | Parsers |
| `lua/plugins/ui.lua` | Blink, Trouble y Snacks |

## Dependencias de inicio

Si lazy.nvim no existe, la configuración ejecuta un `git clone` durante el arranque. Requiere:

```text
git, red, repositorio accesible, directorio escribible
```

## Herencia de LazyVim

La mayoría de funcionalidades no se declaran localmente. Llegan desde LazyVim: explorador, keymaps generales, Git, utilidades, opciones por defecto y plugins adicionales.

La lista exacta depende de la instalación actual. Consultar:

```vim
:Lazy
:lua vim.print(require("lazy").plugins())
:lua vim.print(require("lazy.core.config").plugins)
```

## No confirmable desde los archivos

Estos comportamientos no están garantizados únicamente por el repositorio:

- tecla efectiva de `<leader>`;
- lista exacta de plugins heredados;
- format-on-save efectivo;
- servidores instalados en Mason;
- ejecutables disponibles en PATH;
- keymaps finales después del merge de LazyVim;
- comandos disponibles según versiones instaladas.

## Diferencias con el README original

El README original menciona LSP y herramientas para TypeScript, Rust, Go y C/C++ que no están declarados en los specs locales. La fuente de verdad actual es `lua/plugins/`, más el estado runtime de LazyVim/Mason.

## Validación rápida

```vim
:Lazy
:Mason
:LspInfo
:ConformInfo
:TSInstallInfo
:checkhealth
```
