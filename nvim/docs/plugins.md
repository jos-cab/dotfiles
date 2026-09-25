# Plugins y funcionalidades

## LazyVim y lazy.nvim

`lua/config/lazy.lua`:

- instala lazy.nvim automáticamente si falta;
- importa los plugins base de LazyVim;
- importa todos los specs locales;
- permite instalar, actualizar, limpiar y perfilar plugins;
- desactiva `gzip`, `tarPlugin`, `tohtml`, `tutor` y `zipPlugin`.

Comandos:

```vim
:Lazy
:Lazy sync
:Lazy install
:Lazy update
:Lazy check
:Lazy clean
:Lazy profile
:Lazy log
```

No hay lockfile. `version = false` permite usar commits recientes.

## Catppuccin

`lua/plugins/colorscheme.lua` configura `catppuccin-mocha` como tema activo.

- fondo oscuro Mocha;
- ventanas inactivas atenuadas;
- comentarios y condicionales en cursiva;
- integración con completion, Gitsigns, Neo-tree, Treesitter y mini.nvim;
- fondo no transparente;
- colores de terminal sin modificar.

Cambiar tema activo requiere editar `colorscheme.lua` o usar la configuración de LazyVim.

## Blink.cmp

Completion y snippets. Los atajos están documentados en [Uso diario](uso-diario.md).

Reemplaza `nvim-cmp`, que está deshabilitado en `lua/plugins/disabled.lua`.

## Snacks

Proporciona el dashboard de inicio. El dashboard muestra cabecera ASCII, atajos y estado de inicio.

La configuración local deshabilita los dashboards alternativos Alpha y Mini Starter.

## Telescope

Búsqueda interactiva de archivos, texto, buffers, historial, diagnósticos, comandos y keymaps.

Configuración local:

- estrategia horizontal;
- prompt arriba;
- ancho 90%;
- alto 80%;
- orden ascendente;
- sin transparencia;
- exclusión de directorios generados o dependencias.

## Treesitter

Añade parsing y resaltado estructural para:

```text
bash c cpp css go html javascript json lua markdown
markdown_inline query regex rust toml tsx typescript vim yaml
```

Comandos:

```vim
:TSInstallInfo
:TSInstall <lenguaje>
:TSUpdate
:TSUninstall <lenguaje>
```

## Mason

Instala herramientas externas declaradas en `lua/plugins/tools.lua`:

```text
stylua shellcheck shfmt black ruff prettier jq
```

Comandos:

```vim
:Mason
:MasonInstall <paquete>
:MasonUninstall <paquete>
:MasonUpdate
:MasonLog
```

## Conform

Formateadores por tipo de archivo:

| Tipo | Formateador |
|---|---|
| Lua | Stylua |
| Python | Black, Ruff |
| JavaScript | Prettier |
| TypeScript | Prettier |
| JSON | Prettier |
| YAML | Prettier |
| Markdown | Prettier |
| Shell | Shfmt |

Verificación:

```vim
:ConformInfo
:lua require("conform").format()
```

El formateo al guardar depende de LazyVim; comprobarlo con `:ConformInfo`.

## Trouble

Lista diagnósticos, símbolos y elementos LSP. Tiene preview automático y cierre automático configurados.

## Plugins deshabilitados

- Tokyo Night: reemplazado por Catppuccin.
- Alpha: reemplazado por Snacks.
- Mini Starter: reemplazado por Snacks.
- nvim-cmp: reemplazado por Blink.cmp.
- Persistence: no hay restauración automática mediante ese plugin.
