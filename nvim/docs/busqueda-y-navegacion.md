# Búsqueda y navegación

## Telescope

Telescope se carga mediante el comando `:Telescope` o la tecla `<leader>fp`.

```vim
:Telescope find_files
:Telescope live_grep
:Telescope buffers
:Telescope oldfiles
:Telescope diagnostics
:Telescope keymaps
:Telescope commands
```

`<leader>fp` busca archivos desde la raíz detectada por LazyVim. Los resultados excluyen:

```text
node_modules .git target build dist
```

## Explorador de archivos

LazyVim suele incluir Neo-tree y su atajo `<leader>e`. Confirmar el plugin y comandos instalados:

```vim
:Lazy
:command Neotree
:verbose map <leader>e
```

Si está activo:

```vim
:Neotree
:Neotree toggle
:Neotree reveal
```

## Buffers y ventanas

Los comandos nativos siguen disponibles:

```vim
:ls
:bnext
:bprev
:bdelete
:split
:vsplit
```

LazyVim añade atajos para navegación entre buffers y ventanas. Ver inventario real con:

```vim
:map <leader>
:nmap
```

## Navegación LSP

Con un servidor activo:

```text
gd     definición
gr     referencias
gI     implementación
K      hover
<C-k>  firma
```

## Navegación estructural

Treesitter permite resaltado estructural y habilita funcionalidades dependientes del lenguaje. Parser instalado no equivale a servidor LSP.

## Archivos recientes

LazyVim suele exponer archivos recientes mediante Telescope:

```vim
:Telescope oldfiles
```

## Comprobar el origen de un atajo

```vim
:verbose map <leader>fp
:verbose map <leader>e
:verbose map gd
```

Neovim muestra el archivo que definió el mapping.
