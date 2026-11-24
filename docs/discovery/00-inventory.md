# Discovery inventory

## Executive summary

- **DONE — scope:** personal dotfiles repository for Arch Linux + Hyprland; README §§Overview/System Information, `install.sh:1-451`.
- **DONE — core:** Bash installer symlinks configurations to `$HOME/.config`, configures system-level ananicy, and offers Pacman/AUR packages; `install.sh:148-435`.
- **DONE — design:** Hyprland, Zsh, and Neovim are modularized; `hyprland/hyprland.lua:9-44`, `zsh/zshrc:5-25`, `nvim/lua/`.
- **DONE — cross-cutting automation:** `theme` delegates to `themes/apply`, which regenerates configuration files from templates and a palette; `theme:1-26`, `themes/apply:8-147`.
- **RISK — mutation:** installer can delete existing destinations with `rm -rf`; theme selector overwrites versioned files and external user configurations; `install.sh:82-93`, `themes/apply:42-70,86-136`.

## Directory map

| Path | Classification | DONE |
|---|---|---|
| `/` | orchestration/documentation | `install.sh`, `theme`, `README.md`, `TODO.md`, `LICENSE`, `.gitmodules`, `.gitignore`, `opencode.jsonc`. |
| `hyprland/` | compositor | Lua entry point, 11 modules, local example, scripts; directory listing and `hyprland/hyprland.lua:9-44`. |
| `themes/` | themes | nine `.conf` palettes, `apply`, templates; directory listing. |
| `waybar/` | bar/dock | `config.jsonc`, `dock.jsonc`, two CSS files, scripts; directory listing. |
| `zsh/` | shell | eight modular Zsh files; directory listing. |
| `nvim/` | editor | LazyVim, Lua, lockfile, custom documentation; `nvim/README.md:1-32`. |
| `kitty/`, `wofi/`, `mako/`, `zathura/`, `imv/`, `fastfetch/`, `starship/` | applications | respective configurations; directory listings, `README.md:15-28`. |
| `ananicy/` | scheduler rules | Git submodule with rules; `.gitmodules:4-6`, directory listing. |
| `assets/desktop/` | visual resource | screenshot referenced by README; `README.md:5-7`. |
| `docs/development/` | verification | registered syntax commands; `docs/development/commands.md:1-60`. |
| `docs/discovery/` | discovery | destination directory of this report. |

## Technological inventory

- **DONE — OS/session:** Arch Linux, Wayland, Hyprland Lua; `README.md:3,11-13,30-43`.
- **DONE — languages/format:** Bash (`install.sh`, `theme`, `themes/apply`, scripts); Lua (`hyprland/*.lua`, `nvim/lua/`); Zsh (`zsh/*.zsh`); JSONC (Waybar/Fastfetch); TOML (Starship); CSS; Python at least in `waybar/scripts/media-popup`; `docs/development/commands.md:5-60`.
- **DONE — shell:** Zsh, Zinit, Starship; `README.md:18,34`, `zsh/zshrc:19-25`.
- **DONE — editor:** Neovim based on LazyVim/Lazy.nvim, LSP, Treesitter, Telescope, Mason; `nvim/README.md:1-23`.
- **DONE — UI:** Kitty, Waybar, Wofi, Mako, awww, Zathura, imv, Fastfetch; `README.md:15-28`.
- **DONE — services:** PipeWire/WirePlumber, ananicy-cpp systemd, udiskie, gnome-keyring, EasyEffects, cliphist; `install.sh:128-145,214-224`, `hyprland/autostart.lua:5-27`.
- **HYPOTHESIS — versions:** no version manifest/pins for Pacman/AUR packages. `lazy-lock.json` likely pins Neovim plugins; requires reading it to confirm scope.

## Components and behavior

- **DONE — Hyprland:** loads optional `local`, then modules in explicit order: monitors, programs, autostart, environment, permissions, appearance, animations, layouts, input, keybinds, windowrules; `hyprland/hyprland.lua:31-44`.
- **DONE — session startup:** starts keyring, udiskie, two Waybar instances, Mako, EasyEffects, awww, clipboard watcher, `headroom proxy --port 8787`, `9router`; `hyprland/autostart.lua:4-28`.
- **DONE — Waybar:** modules for energy, workspaces, window, tray, MPRIS, PulseAudio, CPU, memory, temperature, clock; controls execute local scripts, `playerctl`, `pavucontrol`; `waybar/config.jsonc:10-118`.
- **DONE — themes:** palettes Catppuccin Macchiato/Mocha, Dracula, Gruvbox Dark, Nord, One Dark, Rosé Pine, Solitary Massif, Tokyo Night; `themes/` listing. `themes/apply` generates Hyprland, Kitty, Waybar, Wofi, Mako, Zathura, capture script, media popup, Neovim, imv; `themes/apply:8-84`.
- **DONE — external themes:** can modify BetterDiscord, Spicetify, Brave, and VS Code if paths/tools are detected; `themes/apply:86-136`.
- **DONE — installation:** creates symlinks for configurations; `nvim/docs` is excluded; `starship.toml` is symlinked to two destinations; `install.sh:245-413`.
- **DONE — ananicy:** symlinks rules for the user and also installs them to `/etc/ananicy.d`, enables/restarts service with non-interactive sudo; `install.sh:96-136,245-258`.

## Automations

- **DONE — `install.sh`:** initializes submodules, asks for backups/dependencies/shell, optionally installs Pacman/AUR packages, symlinks files, checks PipeWire, verifies five final symlinks; `install.sh:154-158,166-241,439-451`.
- **DONE — update:** script `hyprland/scripts/update-packages` and `system-update/` workflow split into `common`, `checks`, `updates`, `cleanup`, `menu`; script listing and `docs/development/commands.md:8-19`.
- **DONE — productivity:** Hyprland scripts for screenshot, clipboard, color picker, gap adjustment; script listing. README documents screenshot/OCR/QR; `README.md:109-112`.
- **DONE — documented checks:** Bash, Python, Lua, Zsh, and JSONC syntax verified with concrete commands; `docs/development/commands.md:3-60`.
- **UNKNOWN — CI/tests:** inspection found no CI manifest or test suite in the read paths. Confirm hidden tree/remote Git configuration.

## Dependencies

- **DONE — Pacman:** lists compositor/UI, shell, editor/viewers, multimedia, portals, capture, OCR/QR, scheduler, and utilities; `install.sh:214-224`, `README.md:187-207`.
- **DONE — AUR:** `obsidian`, `brave-bin`, `qogir-cursor-theme-git`, via preferred `paru` or `yay`; `install.sh:227-237`, `README.md:209-213`.
- **DONE — minimum verified dependencies:** `hyprland kitty waybar wofi mako zsh starship nvim fastfetch`; `install.sh:35-46`.
- **INCONSISTENCY — dependency:** autostart uses `gnome-keyring-daemon`, `easyeffects`, `headroom`, and `9router`; they do not appear in the Pacman/AUR block of `install.sh:214-237` or README §§Dependencies. Confirm installation/provisioning.
- **INCONSISTENCY — scripts:** README declares OCR and QR; package `tesseract`/`zbar` is listed in installation; `capture-selection` content was not inspected to confirm invocations and error handling.

## Existing documentation

- **DONE — main:** README covers scope, installation, 9Router secrets, components, keybinds, dependencies, resources, and license; `README.md:1-223`.
- **DONE — roadmap:** `TODO.md` records completed items and eight pending ones; `TODO.md:1-18`.
- **DONE — development:** successful validation commands; `docs/development/commands.md:1-60`.
- **DONE — Neovim:** dedicated README describes plugins/languages; `nvim/README.md:1-32`.
- **HYPOTHESIS — operational documentation:** missing explicit rollback instructions, `headroom`/`9router` requirements, template contract, and restoration after `theme`; confirm against uninspected documentation.

## Risks, unknowns, questions

- **RISK — local deletion:** declining backup removes existing destinations via `rm -rf`; `install.sh:82-89`. Question: should per-destination confirmation or a dry-run mode be required?
- **RISK — privileges:** ananicy writes `/etc/ananicy.d` and enables/restarts a service; `install.sh:96-136`. Question: is the submodule rule audited and its Git revision pinned?
- **RISK — secret:** example sets `NINEROUTER_KEY`; `.gitignore` excludes `local.lua`; `hyprland/local.lua.example:1-10`, `.gitignore:1-7`. Question: is the variable exposed to the Hyprland environment visible to child processes/logs?
- **INCONSISTENCY — local order:** example comment states that `local.lua` loads last and overrides values; entry point loads it before all modules; `hyprland/local.lua.example:8`, `hyprland/hyprland.lua:31-44`. Probable effect: subsequent overrides not guaranteed. Correct comment or order after verifying `hl` API.
- **INCONSISTENCY — submodule:** `.gitmodules` declares `ranger/plugins/ranger_devicons`; inspected root directory does not contain `ranger/`; `.gitmodules:1-3`, root map. Confirm if submodule is obsolete or missing.
- **RISK — regeneration:** `themes/apply` replaces repository files, deletes target Spicetify theme, and alters external application preferences; `themes/apply:42-70,106-136`. Question: is a modified Git tree expected after applying a theme?
- **RISK — theme fragility:** substitutions depend on encoded base palette and `.conf` line order; `themes/apply:36-69`. Investigate color count/format validation and output diffs.
- **INCONSISTENCY — versioned runtime:** `themes/templates/__pycache__/media-popupcpython-314.pyc` exists; `themes/templates/` listing. `.gitignore` only excludes `ranger/**/__pycache__/`; `.gitignore:22-29`. Confirm if binary is tracked; expand exclusion/remove if unintentional.
- **UNKNOWN — update security:** package scripts exist, but their content was not inspected. Review privileged commands, confirmations, remote sources, and rollback.
- **UNKNOWN — compatibility:** README claims Arch/Hyprland; actual minimum versions of Hyprland, Lua, Neovim, Waybar, or configuration schema were not inspected.

## Prioritized future research

1. **DONE/HYPOTHESIS:** read `hyprland/{programs,keybinds,environment,ecosystem}.lua` and scripts to build command→dependency→keybind matrix.
2. **DONE/HYPOTHESIS:** audit `themes/apply` with invalid palettes, Git diff, and external paths; define reversible behavior.
3. **DONE/HYPOTHESIS:** review `install.sh` on clean install and existing destinations; check symlinks, permissions, and partial failure.
4. **DONE/HYPOTHESIS:** inspect `nvim/lazy-lock.json`, `nvim/lua/plugins/`, `zsh/zinit.zsh`; inventory remote dependencies and pins.
5. **DONE/HYPOTHESIS:** resolve declared Ranger submodule, missing autostart service dependency, and `local.lua` order.

## Coverage

- **Inspected:** root; `README.md`, `TODO.md`, `.gitignore`, `.gitmodules`, `opencode.jsonc`, `install.sh`, `theme`; component listings; `hyprland/hyprland.lua`, `autostart.lua`, `local.lua.example`; `themes/apply`; `waybar/config.jsonc`; `zsh/zshrc`; `nvim/README.md`; `docs/development/commands.md`.
- **Pending:** content of remaining Hyprland modules, scripts, app configurations, individual templates/palettes, Neovim plugins/lockfile, ananicy submodule, Git history/status, executable permissions, CI, and actual execution.
