# Audit: `theme` and `themes/apply`

> Static inspection. No scripts were executed. Evidence `file:line`.

## Facts

### Selection and input

- `theme` uses strict Bash (`set -euo pipefail`), resolves its own directory with `readlink -f`, and uses it as the root. `theme:1-5`.
- Without an argument, it lists `themes/*.conf` and exits successfully; it does not apply any theme. `theme:7-10`.
- `-h`/`--help` only prints usage. `theme:13-17`.
- An argument containing `/` or a `.conf` suffix is passed through literally; anything else is transformed into `ROOT_DIR/themes/<name>.conf`. `theme:18-23`.
- `theme` replaces its process with `themes/apply`, preserving the applicator’s exit code/signals. `theme:26`.
- `apply` selects Catppuccin Mocha if it does not receive an argument, rejects a nonexistent file with exit status 1. `themes/apply:4-6`.

### Palettes and the implicit contract

- There are nine palettes: `catppuccin-macchiato`, `catppuccin-mocha`, `dracula`, `gruvbox-dark`, `nord`, `one-dark`, `rose-pine`, `solitary-massif`, `tokyo-night`; each contains 24 ordered assignments. `themes/` listing; `themes/catppuccin-mocha.conf:1-24`; `themes/catppuccin-macchiato.conf:1-24`; `themes/dracula.conf:1-24`; `themes/gruvbox-dark.conf:1-24`; `themes/nord.conf:1-24`; `themes/one-dark.conf:1-24`; `themes/rose-pine.conf:1-24`; `themes/solitary-massif.conf:1-24`; `themes/tokyo-night.conf:1-24`.
- The applicator extracts everything after `=` per line, removes spaces and `#`, converts to lowercase; it does not preserve key names. `themes/apply:39`.
- The position, not the key, assigns colors: index 0 feeds the background, 3 `surface0`, 6 text, indices 10--23 semantic colors. `themes/apply:40,53,59-64,91-96,114-115`.
- The `old` matrix contains exactly the 24 hexadecimals of Catppuccin Mocha. `themes/apply:36`; `themes/catppuccin-mocha.conf:1-24`.
- There is no validation of 24 entries, names, hexadecimals, duplicates, or palette syntax before generating; only substitutions whose index does not exist are skipped. `themes/apply:39,48-50`.

### Templates, generated files, and overwrites within the repository

- The applicator maps by index 13 versioned destinations to 13 templates: Hyprland, Kitty (`colors`, `fonts`, `window`), Waybar (`style`, `dock`), Wofi, Mako, Zathura, capture, multimedia popup, Neovim, and imv. `themes/apply:8-17,21-34,42-44`.
- For each destination it requires that the template exists, copies to `mktemp`, substitutes colors/fonts, and atomically moves the temporary file over the destination. `themes/apply:45-51,69-70`.
- `capture-selection` and `media-popup` receive executable permission after writing. `themes/apply:71-73`.
- The general replacement only transforms `rgba(<hex-base>` and `#<hex-base>` from the Mocha matrix; different text in a template does not change. `themes/apply:36,48-51`.
- `imv/config` substitutes only `__BASE__`, `__SURFACE0__`, `__TEXT__`; the template contains these three markers and the base font. `themes/apply:52-54,69`; `themes/templates/imv_config:1-15`.
- Neovim substitutes the 24 markers and selects `macchiato` only when the basename is `catppuccin-macchiato`; any other palette keeps `mocha`. `themes/apply:55-64`.
- The Neovim template declares overrides only under the key `mocha`, even when the generated flavor is `macchiato`. `themes/templates/nvim_colorscheme.lua:7-10,20-46`.
- The special dock rule substitutes only the literal `rgba(30, 30, 46, 0.60)` with the RGB of index 0. `themes/apply:40,66-68`; `themes/templates/waybar_dock.css:13-16`.
- The font comes from `DOTFILES_FONT` or `JetBrainsMono Nerd Font`; it is replaced in the generated files and again in five destinations. `themes/apply:38,69,76-84`.
- Kitty’s template uses that font; `kitty.conf` includes `fonts.conf`, `colors.conf`, and `window.conf`. `themes/templates/kitty_fonts.conf:3-10`; `kitty/kitty.conf:7-14`.
- Headers/comments of multiple templates remain Catppuccin Mocha even after applying another palette. `themes/templates/hyprland_appearance.lua:1-4`; `themes/templates/wofi_style.css:1`; `themes/templates/mako_config:16`; `themes/templates/zathura_zathurarc:2,24,31`.
- `themes/templates/kitty_theme.conf` exists, but it is not shown in the template matrix and is not generated. `themes/` listing; `themes/templates/` listing; `themes/apply:21-34`.
- `themes/templates/spicetify_color.ini` exists, but execution writes `spicetify/color.ini` via `printf`, not from that file. `themes/templates/` listing; `themes/apply:110-117`.
- `themes/templates/__pycache__/` exists; `.gitignore` excludes Python caches only under Ranger paths, not that route. `themes/templates/` listing; `.gitignore:22-29`.

### Outside the repository

- If the BetterDiscord template exists, it always creates `~/.config/BetterDiscord/themes/midnight.theme.css`, even without detecting BetterDiscord installed. `themes/apply:86-98`.
- BetterDiscord is generated from a template that imports remote CSS. `themes/apply:87-96`; `themes/templates/betterdiscord.theme.css:1-13`.
- If `jq` exists and `~/.config/BetterDiscord/data/stable/themes.json` exists, it forces `.midnight = true`; if `jq` fails, it does not move the temporary file. `themes/apply:99-103`.
- Spicetify requires an executable and a config directory; then it recursively removes `~/.config/spicetify/Themes/dotfiles`, copies the template, rewrites `color.ini`, configures six options, and runs `spicetify apply`. `themes/apply:106-125`.
- Brave requires a `Preferences` file and `jq`; then it forces only `browser.theme.is_dark=true`. `themes/apply:129-133`.
- VS Code modifies, if it exists, already-present values of `workbench.colorTheme` and `workbench.iconTheme`; both values are fixed to Catppuccin Mocha/material-icon-theme, regardless of the selected palette. `themes/apply:127,135-136`.
- There is no GTK or Qt writing in `apply`; the internal listed destinations also do not include them. `themes/apply:8-17,21-34,86-136`.

### Verifiable installation and interaction

- `install.sh` installs `theme` as symlink `~/.local/bin/dotfiles-theme` only if the file is executable. `install.sh:391-395`.
- The installer symlinks the directories/files that `apply` overwrites: Hyprland, imv, Kitty, Mako, Neovim, Waybar, Wofi, and Zathura. `install.sh:260-271,286-290,303-318,320-336,349-372,374-389`.
- Therefore, after an installation with those symlinks, overwrites within the repository are visible in the linked `~/.config` paths. `install.sh:260-271,286-290,303-318,320-336,349-389`; `themes/apply:8-17,70`.
- `create_symlink` backs up destinations only with the backups option enabled; without it, it runs `rm -rf` on the previous destination. `install.sh:48-64,67-94`.
- The installer’s final verification only checks the main symlinks; it does not apply a theme and does not verify its templates, palettes, or outputs. `install.sh:437-450`.

### Dependencies, reload, and errors

- The applicator uses Bash, `awk`, `mapfile`, `perl`, `mktemp`, `cp`, `mv`, `mkdir`, `chmod`, `basename`, and `printf` directly. `themes/apply:1-5,37,39-40,46-47,50,69-73,89-90,97,101,107-117`.
- `jq` is optional for BetterDiscord and Brave; `spicetify`, `hyprctl`, `waybar`, `pkill`, `makoctl` are conditional detections. `themes/apply:100-103,106,130-133,138-146`.
- The installer includes `jq` in its package list, but its basic check does not verify `perl`, `jq`, Spicetify, or capture/popup tooling. `install.sh:35-46,215-222`.
- After generating, it tries to reload Hyprland, kills and restarts Waybar, starts the dock if its linked files exist, reloads Mako, and prints the applied theme. Reload failures are explicitly ignored. `themes/apply:138-147`.
- The generated popup imports PyGObject/GDK/Gtk/GtkLayerShell and calls `playerctl`; these dependencies are not verified during `apply`. `themes/templates/media-popup:1-21`.
- The generated capture script verifies `grimblast`, `wl-copy`, and depending on the action `tesseract`/`zbarimg`; these are not verified during application. `themes/templates/capture-selection:16-20,33-34,50-65`.
- There is documented Bash syntax checking for `install.sh`, `theme`, and `themes/apply`; the document states it only enumerates successful-exit commands. `docs/development/commands.md:1-9`.

## Verified inconsistencies

- README lists seven themes and omits `solitary-massif`, even though that file exists and the selector lists all `themes/*.conf`. `README.md:121-122`; `themes/` listing; `theme:7-10`.
- README promises GTK and Qt theming; `apply` has no GTK/Qt destinations or writes. `README.md:121-129`; `themes/apply:8-17,21-34,86-136`.
- README claims restarting open applications reloads the theme, while the applicator attempts to reload Hyprland/Mako and restart Waybar. `README.md:129`; `themes/apply:138-146`.
- README calls the system centralized; VS Code stays fixed to Mocha and Neovim uses the Macchiato flavor only for one of nine palettes. `README.md:119-129`; `themes/apply:55-58,127,135-136`.

## Hypotheses and unknowns

- **Possible Neovim/Macchiato incompatibility:** the palette is written under `mocha` override while the `macchiato` flavor is selected; missing execution to confirm whether Catppuccin ignores those overrides. Structural evidence: `themes/apply:55-64`; `themes/templates/nvim_colorscheme.lua:7-10,20-46`.
- **Possible invalid output with malformed palette:** missing validations and substitutions use indices/hexadecimals directly; missing execution to confirm the failure point and partially written files. `themes/apply:39-40,48-50,53,59-64`.
- **Unknown:** if each application accepts the produced values, including non-Catppuccin semantic duplicates of palettes. The applicator does not validate outputs. `themes/apply:39-70`.
- **Unknown:** Git state of `__pycache__`; available inspection shows presence/absence of a specific exclusion, not tracking. `themes/templates/` listing; `.gitignore:22-29`.
- **Unknown:** compatibility of BetterDiscord/Spicetify/Brave/VS Code with the hard-coded paths and formats. Inspection did not execute applications. `themes/apply:86-136`.

## Restore

- There is no restore command, prior copy, or restore mechanism in `theme`/`apply`. `theme:1-26`; `themes/apply:1-147`.
- Reapplying another palette regenerates the 13 destinations from templates, but does not restore manual edits or previous external states. `themes/apply:42-74,86-136`.
- `.bak` copies belong to the symlinking in `install.sh`, not to the theming application. `install.sh:48-64,82-93`.

## Closing

### Verified risks

- Overwrite of 13 repository files without backup. `themes/apply:42-74`.
- Create/overwrite BetterDiscord without detecting the application. `themes/apply:86-104`.
- Recursive deletion of the Spicetify theme `dotfiles`. `themes/apply:106-109`.
- VS Code preferences fixed to Mocha for every palette. `themes/apply:127,135-136`.
- No dedicated restore path. `theme:1-26`; `themes/apply:1-147`.

### Potential risks

- A short or invalid palette may generate partial or invalid configuration. `themes/apply:39-40,48-50`.
- Macchiato may not receive Neovim overrides. `themes/apply:55-64`; `themes/templates/nvim_colorscheme.lua:7-10,20-46`.
- Remote CSS from BetterDiscord adds a network/third-party dependency at load time. `themes/templates/betterdiscord.theme.css:7-13`.

### Observed decisions

- Single palette source, Mocha templates, positional substitution. `themes/apply:36-40,42-70`.
- Direct mutation of the tree so installed symlinks reflect changes. `themes/apply:8-17,70`; `install.sh:260-389`.
- External integrations mostly conditional; BetterDiscord is the exception. `themes/apply:86-136`.

### Not inspected

- Actual execution, produced diffs, exit codes for invalid palettes, reloads, formats accepted by consumers, and complete subsystem contents for non-thematic parts. No scripts were executed.
