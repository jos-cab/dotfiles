# Personalización y mantenimiento

## Estructura

```text
init.lua
lua/config/lazy.lua
lua/config/options.lua
lua/config/keymaps.lua
lua/config/autocmds.lua
lua/plugins/*.lua
```

- `config/lazy.lua`: bootstrap y carga.
- `config/options.lua`: opciones globales; actualmente sin personalizaciones.
- `config/keymaps.lua`: atajos propios; actualmente vacío funcionalmente.
- `config/autocmds.lua`: eventos propios; actualmente vacío funcionalmente.
- `plugins/`: specs que extienden LazyVim.

## Añadir un plugin

Crear un spec en `lua/plugins/`:

```lua
return {
  {
    "autor/plugin",
    opts = {},
  },
}
```

Usar `event`, `cmd`, `keys` o `ft` solo cuando el plugin pueda cargarse bajo demanda.

## Añadir un atajo

Editar `lua/config/keymaps.lua` siguiendo el estilo existente de LazyVim. Antes, comprobar si ya existe un mapping:

```vim
:verbose map <leader>x
```

## Añadir un LSP o herramienta

- LSP: editar `lua/plugins/lsp.lua`.
- Herramienta externa: editar `lua/plugins/tools.lua`.
- Parser: editar `lua/plugins/treesitter.lua`.
- Formateador: añadirlo en `formatters_by_ft`.

Después:

```vim
:Lazy sync
:Mason
:LspInfo
:ConformInfo
```

## Actualizar

```vim
:Lazy check
:Lazy update
```

Sin `lazy-lock.json`, las actualizaciones no son reproducibles. Si se necesita estabilidad, conservar el lockfile generado por Lazy.

## Diagnóstico

```vim
:checkhealth
:Lazy debug
:Lazy profile
:MasonLog
:LspLog
:ConformInfo
```

Comprobación headless:

```bash
nvim --headless -u init.lua "+checkhealth" "+qa"
```

## Puntos a vigilar

- El arranque inicial necesita Git, red y permisos de escritura.
- `format_on_save` no está declarado localmente; depende de LazyVim.
- Los LSP declarados no se incluyen en `ensure_installed` de Mason.
- El README original enumera servidores y herramientas que no aparecen en la configuración actual.
- Stylua declara tabs en `stylua.toml`, mientras los Lua actuales usan dos espacios.
- Plugins heredados dependen de la versión instalada de LazyVim.
