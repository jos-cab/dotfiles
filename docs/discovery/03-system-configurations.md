# System configurations

## 1. Scope and method

- **FACT:** static review, without executing scripts or mutating commands. Coverage: installation, Hyprland, scripts, Zsh, Neovim, system updater, local Git, declared dependencies. Evidence: `install.sh:1-451`, `hyprland/`, `zsh/`, `nvim/`, `.git/config:1-18`.
- **UNKNOWN:** effective state of Arch, services, packages, permissions, environment variables, global Git config, and reachable remotes; nothing was queried or changed.
- **LIMIT:** this report describes version-controlled code and the local `.git/config`; it does not certify runtime behavior.

## 2. Platform, installation, and dependencies

- **FACT:** stated goal: Arch Linux with Hyprland/Wayland; Linux is not a blocking requirement for the installer. Evidence: `README.md:3,11-13,30-43`; `install.sh:28-33`.
- **FACT:** `install.sh` uses Bash with `set -e`, initializes submodules, and links configuration under `$HOME/.config`; it offers to switch the shell to Zsh. Evidence: `install.sh:7,148-158,245-435`.
- **FACT:** declared official packages include Hyprland, Kitty, Waybar, Wofi, Mako, PipeWire, portals, capture/OCR/QR, ananicy-cpp, Neovim, and utilities. AUR: `obsidian`, `brave-bin`, `qogir-cursor-theme-git`. Evidence: `install.sh:214-237`; `README.md:187-213`.
- **FACT:** accepted installation runs `pacman -S ... --noconfirm`; if present, `paru` or `yay` installs AUR packages too without confirmation. Evidence: `install.sh:205-237`.
- **RISK:** existing destinations are recursively deleted if backups are not enabled; invalid input chooses not to back up. Evidence: `install.sh:82-93,168-184`.
- **HYPOTHESIS:** `grimblast` is a functional missing dependency: the capture flow requires it, Pacman installs `grim` and `slurp`, not `grimblast`. Verify the package/provision. Evidence: `hyprland/scripts/capture-selection:23-34`; `install.sh:221-223`.

## 3. Hyprland: loading, environment, and hardware

- **FACT:** the Lua entry point adds `~/.config/hypr` and `$DOTFILES_DIR/hyprland` to `package.path`, loads `local` with `pcall`, then loads modules in a fixed order. Evidence: `hyprland/hyprland.lua:22-44`.
- **FACT:** the generic monitor uses empty output, preferred mode, automatic position and scaling. Evidence: `hyprland/monitors.lua:4-9`.
- **FACT:** input assumes a `latam` keyboard, an active Numpad, and a `razer-razer-naga-chroma` mouse with flat acceleration. Evidence: `hyprland/input.lua:4-17`.
- **FACT:** exports Qogir cursor, Vulkan/WLR, NVIDIA VA-API, Qt6ct, the local 9Router endpoint, `bat` as the pager, and a remote Restic repository. Evidence: `hyprland/environment.lua:4-13`.
- **RISK:** `RESTIC_REPOSITORY` reveals backup topology/name even without the password; the password is referenced via a local file. Evidence: `hyprland/environment.lua:13`; `zsh/environment.zsh:137-138`.
- **INCONSISTENCY:** the example claims `local.lua` loads last and takes precedence, but it is loaded before all modules; later values can overwrite it. Evidence: `hyprland/local.lua.example:8`; `hyprland/hyprland.lua:31-44`.
- **FACT:** expected 9Router secret in `local.lua`; Git ignores local variants. Evidence: `hyprland/local.lua.example:1-10`; `.gitignore:1-7`.

## 4. Hyprland: interface, permissions, and shortcuts

- **FACT:** Dwindle layout with gaps 5/10, border 2, rounding 12; no blur or shadows; tearing allowed. Evidence: `hyprland/appearance.lua:5-48`; `hyprland/layouts.lua:3-17`.
- **FACT:** animations are enabled; rules float/center the GTK portal and disable animation for the `Media controls` window. Evidence: `hyprland/animations.lua:4-31`; `hyprland/windowrules.lua:4-16`.
- **FACT:** `ecosystem.enforce_permissions` is disabled and specific permissions remain commented out. Evidence: `hyprland/ecosystem.lua:4-12`.
- **FACT:** linked programs: Kitty, Thunar, Brave Wayland, Discord, Spotify Launcher, `zeditor`, Wofi. Evidence: `hyprland/programs.lua:4-12`; `hyprland/keybinds.lua:5-19`.
- **FACT:** shortcuts run update, color picker, clipboard history, capture/OCR/QR, Waybar dock, window/workspace control, and shutdown/reboot/lock/kill actions. Evidence: `hyprland/keybinds.lua:17-121`.
- **RISK:** `SUPER+SHIFT+Delete` calls `poweroff`; `SUPER+CTRL+Delete` calls `reboot`; no confirmation is configured. Evidence: `hyprland/keybinds.lua:102-106`.

## 5. Hyprland: startup and operational scripts

- **FACT:** login starts keyring, udiskie, two Waybar instances, Mako, EasyEffects, awww, clipboard watcher `cliphist`, `headroom proxy --port 8787`, and `9router`. Evidence: `hyprland/autostart.lua:4-28`.
- **INCONSISTENCY:** `gnome-keyring-daemon`, `easyeffects`, `headroom`, and `9router` are invoked but do not appear in the installer’s Pacman/AUR package lists. Evidence: `hyprland/autostart.lua:6,17,26-27`; `install.sh:214-237`.
- **FACT:** capture validates commands, uses a temporary file, and uses `trap`; it supports copying, saving, OCR, and QR. Evidence: `hyprland/scripts/capture-selection:3-82`.
- **FACT:** clipboard history requires `cliphist`, `wl-copy`, and Wofi; it creates temporary files/directories, deletes everything with `trap`, and limits items via a variable. Evidence: `hyprland/scripts/clipboard-history:3-83,111-145`.
- **FACT:** `adjust_gaps` changes runtime values via `hyprctl eval`; it does not persist changes to files. Evidence: `hyprland/scripts/adjust_gaps:8-56`.
- **HYPOTHESIS:** parsing `hyprctl getoption` depends on the current textual output format; a Hyprland update may prevent reading values. Evidence: `hyprland/scripts/adjust_gaps:14-25,31-34`.

## 6. System update and maintenance

- **FACT:** `SUPER+U` opens a modular updater in Kitty; it requires TTY, locks via `flock`, writes logs under `$XDG_STATE_HOME/system-update`, and keeps a maximum of ten logs before rotation. Evidence: `hyprland/scripts/update-packages:5-18`; `hyprland/scripts/system-update/system-update.sh:77-102`; `hyprland/scripts/system-update/lib/common.sh:11-25,165-170`.
- **FACT:** full update performs preflight, `paru -Syu --noconfirm --skipreview`, global npm only if the prefix belongs to `$HOME`, `uv tool upgrade --all`, `pipx upgrade-all`, postflight, and cleanup. Evidence: `hyprland/scripts/system-update/system-update.sh:22-30`; `hyprland/scripts/system-update/lib/updates.sh:44-144`.
- **FACT:** `AUTO_CONFIRM=1`; `confirm` functions return automatic acceptance. In cleanup flows, this allows deleting Paru clone cache, orphans, and, when running full cleanup, Pacman/journal cache. Evidence: `hyprland/scripts/system-update/lib/common.sh:15,145-163`; `hyprland/scripts/system-update/lib/cleanup.sh:60-109,140-157`.
- **RISK:** AUR updates without review and automatic confirmation for maintenance; orphaned packages are removed with `sudo pacman -Rns --noconfirm`. Evidence: `hyprland/scripts/system-update/lib/updates.sh:45-58`; `hyprland/scripts/system-update/lib/cleanup.sh:91-105`.
- **FACT:** preflight detects Pacman lock; it can delete a considered-stale lock with sudo; postflight checks services, integrity, `.pacnew`, AUR/manuals, bootloader, journal, and reboot. Evidence: `hyprland/scripts/system-update/lib/checks.sh:49-82,153-161,361-370`.
- **UNKNOWN:** adequacy of lock/orphan/cache detection for the real system; requires controlled execution outside of this discovery.

## 7. Zsh: loading, environment, and integrations

- **FACT:** `~/.zshrc` resolves its directory and loads Zinit, environment, aliases, functions, completion, plugins, and integrations; it shows `fastfetch` if present and loads `local.zsh`, which Git ignores. Evidence: `zsh/zshrc:15-33`; `.gitignore:1-7`.
- **FACT:** if Zinit does not exist, initialization clones without pinning `https://github.com/zdharma-continuum/zinit`; then it loads four annexes and three plugins by remote name. Evidence: `zsh/zinit.zsh:5-23`; `zsh/plugins.zsh:4-12`.
- **RISK:** the first shell requires network access and executes unpinned remote repository code. Evidence: `zsh/zinit.zsh:5-13`; `zsh/plugins.zsh:6-12`.
- **FACT:** environment fixes the Neovim editor, shared history of 10,000 entries, locale `C.utf8`, Java 21, local paths/Spicetify, NVIDIA VA-API, Qt6ct, XDG, and a Restic password file. Evidence: `zsh/environment.zsh:4-22,93-138`.
- **FACT:** conditional integrations initialize FZF, Starship, Zoxide, Eza, Bat, Delta, NVM, Pyenv, Poetry, RVM, Cargo, Go, SDKMAN, Docker, Kubectl, Kiro, Kitty, and ssh-agent. Evidence: `zsh/integrations.zsh:4-140`.
- **RISK:** if `SSH_AUTH_SOCK` is missing, it runs `source "$XDG_RUNTIME_DIR/ssh-agent.env"`; a missing or manipulated file can cause an error or local-content evaluation. Evidence: `zsh/integrations.zsh:134-141`.

## 8. Zsh: commands, functions, and networking

- **FACT:** aliases replace `ls`/`cat` with `eza`/`bat`, elevate `pacman` to `sudo pacman`, redefine Brave with `--password-store=basic`, and provide Git, development, and navigation operations. Evidence: `zsh/aliases.zsh:4-84`.
- **RISK:** `brave` uses `--password-store=basic`, reducing integration with the system credential store. Evidence: `zsh/aliases.zsh:67`; `hyprland/programs.lua:7`.
- **FACT:** functions include extraction, Git clone/commit, killing processes, an HTTP server, mass replacement with `sed -i`, FZF, and Docker operations. Evidence: `zsh/functions.zsh:6-144`.
- **RISK:** `killall()` kills PIDs found via `grep`; `findreplace()` applies a `sed` expression provided by the user to all files; `docker-cleanup()` prunes images/volumes without confirmation. Evidence: `zsh/functions.zsh:50-52,75-82,134-139`.
- **FACT:** several aliases/functions send data or HTTP requests to external services, some without TLS: `ipecho.net`, `api.open-notify.org`, wttr.in, qrenco.de, cheat.sh, and others. Evidence: `zsh/aliases.zsh:46-47,82-85,91,99-108`; `zsh/functions.zsh:55-59,85-100`.
- **HYPOTHESIS:** `compinit` without audit options can warn or reject insecure permissions depending on the local state of `$fpath`; no explicit handling exists. Evidence: `zsh/completions.zsh:5-7`.

## 9. Neovim: architecture, plugins, and tools

- **FACT:** `init.lua` loads `config.lazy`; bootstrap clones `lazy.nvim` the `stable` branch when missing, imports LazyVim and local plugins. Evidence: `nvim/init.lua:1-2`; `nvim/lua/config/lazy.lua:1-23`.
- **FACT:** the lockfile records SHA for 31 plugins, including LazyVim, lazy.nvim, Mason, LSP, Treesitter, Telescope, Catppuccin, and Blink. Evidence: `nvim/lazy-lock.json:1-33`.
- **INFERENCE:** bootstrap of `lazy.nvim` does not use the lockfile SHA for the first clone; afterwards Lazy can resolve the locked state. Evidence: `nvim/lua/config/lazy.lua:3-14`; `nvim/lazy-lock.json:11`.
- **FACT:** periodic update verification is active without notifications; the default plugin configuration uses `version = false`. Evidence: `nvim/lua/config/lazy.lua:24-37`.
- **FACT:** the custom LSP enables `lua_ls`, `pyright`, `jsonls`, `bashls`; Mason ensures formatters/linters for Lua, shell, Python, JS/TS, and JSON/YAML. Evidence: `nvim/lua/plugins/lsp.lua:1-37`; `nvim/lua/plugins/tools.lua:1-40`.
- **INCONSISTENCY:** the README declares TypeScript, Rust, Go, and C/C++ preconfigured, but the inspected local configuration only declares four servers; base LazyVim may provide others, but that is not proven statically. Evidence: `nvim/README.md:15-23`; `nvim/lua/plugins/lsp.lua:6-34`.
- **FACT:** the Catppuccin Mocha theme uses its own overrides; Treesitter requests 20 parsers; UI contributes an adaptable dashboard and Blink/Trouble. Evidence: `nvim/lua/plugins/colorscheme.lua:1-67`; `nvim/lua/plugins/treesitter.lua:1-31`; `nvim/lua/plugins/ui.lua:99-193`.

## 10. Git, submodules, controls, and pending work

- **FACT:** Git repository is not bare, `filemode=true`, `main` branch tracks `origin/main`; remote `origin` uses SSH `git@github.com:jos-cab/dotfiles.git`. Evidence: `.git/config:1-18`.
- **FACT:** configured submodules: `ananicy` from CachyOS and `ranger/plugins/ranger_devicons` from GitHub; the installer updates both recursively. Evidence: `.gitmodules:1-6`; `.git/config:10-15`; `install.sh:154-158`.
- **INCONSISTENCY:** `.gitmodules` declares Ranger, but the inspected root tree does not contain `ranger/`; the installer does not link it. Verify whether the submodule is obsolete, uninitialized, or missing. Evidence: `.gitmodules:1-3`; `install.sh:245-435`.
- **FACT:** ananicy is linked for the user and, with `sudo -n`, is copied to `/etc/ananicy.d`; it enables/starts/restarts the service. Evidence: `install.sh:96-135,245-258`.
- **RISK:** this privileged change does not request a password; it depends on submodule rules and can leave a partial state due to `set -e`. Evidence: `install.sh:7,111-132`.
- **FACT:** documented syntax commands cover Bash, Python, Lua, Zsh, and JSONC; the document states the results are OK. Evidence: `docs/development/commands.md:1-60`.
- **UNKNOWN:** no version-controlled user Git configuration, hooks, commit signing, CI, update policy, or functional tests were found. Next step: confirm with the owner before introducing controls or changes.
