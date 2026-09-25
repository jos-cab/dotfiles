# Uso diario

## Abrir y salir

```bash
nvim archivo
nvim .
```

Comandos base de Neovim:

```vim
:w       guardar
:q       salir
:wq      guardar y salir
:q!      salir descartando cambios
:e ruta  abrir archivo
```

## Leader

La tecla `<leader>` no se define en esta configuración. LazyVim normalmente usa espacio, pero comprobar con:

```vim
:lua print(vim.g.mapleader)
```

## Búsqueda y archivos

Atajos comunes provistos por LazyVim:

```text
<leader>ff   buscar archivos
<leader>fg   buscar texto
<leader>fr   archivos recientes
<leader>fb   buffers
<leader>e    explorador de archivos
```

La configuración local añade:

```text
<leader>fp   buscar archivos de plugins desde la raíz de LazyVim
```

Comandos Telescope:

```vim
:Telescope find_files
:Telescope live_grep
:Telescope buffers
:Telescope oldfiles
:Telescope diagnostics
:Telescope keymaps
:Telescope commands
```

Telescope ignora `node_modules`, `.git`, `target`, `build` y `dist`.

## Código

Atajos LSP habituales de LazyVim:

```text
gd           definición
gr           referencias
gI           implementación
K            documentación hover
<C-k>        firma
<leader>ca   acciones de código
<leader>cr   renombrar símbolo
[d / ]d       diagnóstico anterior / siguiente
```

Comprobar el origen exacto de cualquier atajo:

```vim
:verbose map gd
:verbose map <leader>ca
```

## Completion

Blink.cmp funciona dentro del menú de completado:

```text
<CR>       aceptar
<Tab>      avanzar snippet, aceptar o siguiente opción
<S-Tab>    retroceder snippet u opción anterior
<C-Space>  mostrar completion/documentación
<C-e>      ocultar
<Up>       opción anterior
<Down>     opción siguiente
```

## Diagnósticos

Trouble muestra diagnósticos, símbolos y referencias:

```text
<leader>xx   lista de diagnósticos
```

Comandos disponibles según la versión instalada:

```vim
:Trouble
:Trouble diagnostics toggle
:Trouble symbols toggle
:Trouble lsp toggle
```

## Git

LazyVim aporta integración visual de Git, normalmente mediante Gitsigns y comandos/atajos del propio entorno. Inspección:

```vim
:Lazy
:map <leader>
```

## Ayuda

```vim
:help lazyvim
:help key-notation
:checkhealth
```
