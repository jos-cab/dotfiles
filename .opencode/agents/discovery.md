---
description: Descubre el repositorio. Solo lee. Solo puede escribir informes en docs/discovery/.
mode: subagent
permissions:
  - action: "*"
    resource: "*"
    effect: deny
  - action: read
    resource: "*"
    effect: allow
  - action: glob
    resource: "*"
    effect: allow
  - action: grep
    resource: "*"
    effect: allow
  - action: edit
    resource: "docs/discovery/**"
    effect: allow
  - action: shell
    resource: "*"
    effect: deny
  - action: subagent
    resource: "*"
    effect: deny
---
Inspeccioná el repositorio. No modifiques archivos fuera de `docs/discovery/`. Escribí hallazgos únicamente allí.
