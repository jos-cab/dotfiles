# Verified Commands

Executed from the repository root. Only commands with successful output are listed.

## Bash Syntax

```sh
bash -n install.sh theme themes/apply \
  hyprland/scripts/capture-selection \
  hyprland/scripts/clipboard-history \
  hyprland/scripts/color-picker \
  hyprland/scripts/adjust_gaps \
  hyprland/scripts/update-packages \
  hyprland/scripts/system-update/system-update.sh \
  hyprland/scripts/system-update/lib/common.sh \
  hyprland/scripts/system-update/lib/checks.sh \
  hyprland/scripts/system-update/lib/updates.sh \
  hyprland/scripts/system-update/lib/cleanup.sh \
  hyprland/scripts/system-update/lib/menu.sh \
  waybar/scripts/media-popup-toggle \
  waybar/scripts/power-menu.sh \
  waybar/scripts/power-confirm.sh \
  waybar/scripts/reboot-confirm.sh
```

Result: OK.

## Python Syntax

```sh
python3 -m py_compile waybar/scripts/media-popup
```

Result: OK.

## Lua Syntax

```sh
find hyprland nvim -type f -name '*.lua' -print0 | xargs -0 -r -n1 luac -p
```

Result: OK.

## Zsh Syntax

```sh
zsh -n zsh/zshrc zsh/zinit.zsh zsh/environment.zsh zsh/aliases.zsh \
   zsh/functions.zsh zsh/completions.zsh zsh/plugins.zsh zsh/integrations.zsh
```

Result: OK.

## Waybar JSONC

```sh
sed -E 's@//.*$@@; s@/\*([^*]|\*[^/])*\*/@@g' waybar/config.jsonc | jq empty
sed -E 's@//.*$@@; s@/\*([^*]|\*[^/])*\*/@@g' waybar/dock.jsonc | jq empty
```

Result: OK.
