# Configuración de Neovim

Documentación de la configuración ubicada en `dotfiles/nvim`.

## Resumen

- Base: LazyVim.
- Gestor: lazy.nvim.
- Tema: Catppuccin Mocha.
- Completion: Blink.cmp.
- LSP declarado: Lua, Python, JSON y Bash.
- Formateo: Conform + Stylua, Black, Ruff, Prettier y Shfmt.
- Syntax highlighting: Treesitter.
- Búsqueda: Telescope.
- Diagnósticos: Trouble.
- Herramientas: Mason.
- Dashboard: Snacks.

## Inicio

`init.lua` carga `config.lazy`. Esa configuración instala lazy.nvim si no existe, importa LazyVim y luego todos los archivos de `lua/plugins/`.

Los plugins locales son eager por defecto. Telescope es la excepción principal: se carga al usar `:Telescope` o `<leader>fp`.

## Documentos

- [Uso diario](uso-diario.md): acciones, atajos y comandos frecuentes.
- [Plugins](plugins.md): plugins y funcionalidades.
- [LSP y desarrollo](lsp-y-desarrollo.md): servidores, completion, diagnósticos y formato.
- [Búsqueda y navegación](busqueda-y-navegacion.md): Telescope, explorador y navegación.
- [Personalización](personalizacion.md): estructura, mantenimiento y verificación.
- [Inventario técnico](inventario-tecnico.md): fuente declarativa, límites y advertencias.

## Ver el estado real

La configuración hereda muchos atajos y plugins de la versión instalada de LazyVim. Para inspeccionarlos dentro de Neovim:

```vim
:Lazy
:map <leader>
:verbose map <leader>fp
:LspInfo
:Mason
:checkhealth
```

No hay `lazy-lock.json`; las versiones pueden cambiar al actualizar.
