# LSP y desarrollo

## Servidores configurados

`lua/plugins/lsp.lua` declara cuatro servidores:

| Servidor | Lenguaje | Ajuste |
|---|---|---|
| `lua_ls` | Lua | no comprueba librerías de terceros; snippets en modo Replace |
| `pyright` | Python | type checking básico |
| `jsonls` | JSON | configuración por defecto |
| `bashls` | Bash | configuración por defecto |

Estado y logs:

```vim
:LspInfo
:LspStart
:LspStop
:LspRestart
:LspLog
```

## Capacidades LSP

Cuando el servidor y el buffer las soportan:

- autocompletado;
- hover/documentación;
- ir a definición;
- referencias;
- implementación;
- renombrado;
- acciones de código;
- diagnósticos;
- ayuda de firma;
- formato.

Los atajos exactos pueden variar según la versión de LazyVim. Consultarlos con `:map <leader>` y `:verbose map <atajo>`.

## Completion

Blink.cmp combina fuentes LSP, snippets y otras fuentes habilitadas por LazyVim. `<C-Space>` abre el menú; `<CR>` acepta la selección.

## Formato

Conform selecciona formateador según `&filetype`. Formateadores requeridos:

```text
lua       stylua
python    black, ruff_format
javascript/typescript/json/yaml/markdown  prettier
sh        shfmt
```

`ruff_format` usa la integración del ejecutable `ruff`; validar con:

```vim
:ConformInfo
```

## Herramientas externas

Mason instala herramientas, pero la configuración local no incluye explícitamente los ejecutables de los cuatro LSP. Revisar su disponibilidad en `:Mason`.

## Archivos compatibles declarados

```text
Lua, Python, JSON, Bash
JavaScript, TypeScript, YAML, Markdown, Shell
C, C++, CSS, Go, HTML, Rust, TOML
```

Los últimos lenguajes tienen Treesitter declarado; no implica que tengan LSP o formateador configurado.

## Diagnósticos

Los diagnósticos del LSP aparecen en el buffer y pueden abrirse en Trouble. Atajos habituales:

```text
[d / ]d   diagnóstico anterior / siguiente
<leader>xx lista de diagnósticos
```
