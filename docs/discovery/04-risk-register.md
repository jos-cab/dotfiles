# Risk register

## Scope and method

Static synthesis of discovery reports `00`–`03`; no scripts were executed and no configuration was changed. Status distinguishes **confirmed** (directly evidenced), **hypothesis** (plausible but unverified), and **unknown** (insufficient evidence).

## Severity criteria

| Severity | Criterion |
|---|---|
| Critical | Can destroy user/system state, expose credentials, or make the system unavailable without a reliable recovery path. |
| High | Can cause persistent privileged change, significant loss, supply-chain exposure, or unsafe maintenance action; recovery is manual or uncertain. |
| Medium | Can break an expected feature, create inconsistent state, or weaken security; impact is bounded or requires a condition. |
| Low | Documentation, hygiene, or compatibility gap with limited direct impact. |

## Register

| ID | Severity | Status | Risk | Evidence | Owner decision / blocker | Recommended disposition |
|---|---|---|---|---|---|---|
| R-01 | Critical | Confirmed | Installation can recursively delete every pre-existing destination when backups are declined; invalid backup input also declines backups. No transactional restore exists. | `install.sh:82-93`; `install.sh:168-184`; `install.sh:52-65`; `install.sh:1-451` | Owner: repository maintainer. Blocker: define accepted non-interactive and overwrite policy. | Do not make destructive replacement the fallback; provide preview, explicit per-run consent, and documented restore. |
| R-02 | High | Confirmed | Installation changes destinations one at a time; an unhandled failure can leave mixed old/new configuration without rollback. | `install.sh:7`; `install.sh:58`; `install.sh:245-435`; `install.sh:1-451` | Owner: repository maintainer. Blocker: choose rollback scope for files, links, and system changes. | Record completed mutations and restore them on failure/interruption, or clearly stage changes before commit. |
| R-03 | High | Confirmed | Ananicy setup can write `/etc/ananicy.d` and enable/start/restart a system service using non-interactive sudo. | `install.sh:98-132`; `install.sh:245-258` | Owner: system owner. Blocker: audit and pin the ananicy submodule revision/rules. | Separate privileged setup, show planned changes, require explicit consent, document reversal. |
| R-04 | High | Confirmed | The system updater automatically accepts AUR updates and cleanup; cleanup can remove orphan packages with `sudo pacman -Rns --noconfirm`. | `hyprland/scripts/system-update/lib/updates.sh:45-58`; `hyprland/scripts/system-update/lib/common.sh:15,145-163`; `hyprland/scripts/system-update/lib/cleanup.sh:91-105` | Owner: system owner. Blocker: decide whether unattended updates are intentional. | Require review/confirmation for AUR and removals; preserve logs and a recovery procedure. |
| R-05 | High | Confirmed | First Zsh startup clones and loads remote Zinit/plugins without a revision pin. | `zsh/zinit.zsh:5-23`; `zsh/plugins.zsh:4-12` | Owner: repository maintainer. Blocker: select trusted revisions and update process. | Pin revisions and document verification/update ownership. |
| R-06 | High | Confirmed | Theme application overwrites 13 repository-managed outputs and external application state without its own backup/restore; it recursively removes the Spicetify theme directory. | `themes/apply:42-74`; `themes/apply:86-136`; `themes/apply:106-125`; `theme:1-26` | Owner: repository maintainer. Blocker: decide whether generated files remain versioned and which external integrations are opt-in. | Validate first, preview diffs, back up changed destinations, and provide restore. |
| R-07 | Medium | Confirmed | BetterDiscord theme generation imports remote CSS at application runtime, creating a third-party network/content dependency. | `themes/templates/betterdiscord.theme.css:7-13`; `themes/apply:87-96` | Owner: system owner. Blocker: approve remote dependency or vendor/version it. | Make integration opt-in; pin or vendor the stylesheet where licensing permits. |
| R-08 | Medium | Confirmed | `local.lua` is loaded before standard modules although its example promises last-load override behavior; local settings can be overwritten. | `hyprland/local.lua.example:8`; `hyprland/hyprland.lua:31-44` | Owner: repository maintainer. Blocker: intended precedence. | Align load order or documentation; test a representative override. |
| R-09 | Medium | Confirmed | Autostart invokes `gnome-keyring-daemon`, `easyeffects`, `headroom`, and `9router`, absent from declared installer package lists. | `hyprland/autostart.lua:6,17,26-27`; `install.sh:214-237` | Owner: repository maintainer. Blocker: establish installation source for each command. | Declare, detect, or conditionally skip each dependency with actionable diagnostics. |
| R-10 | Medium | Hypothesis | Malformed or short palettes may produce invalid or incomplete generated configuration because palette shape and hexadecimal values are not validated. | `themes/apply:39-40`; `themes/apply:48-50`; `themes/apply:53`; `themes/apply:59-64` | Owner: repository maintainer. Blocker: controlled fixture test; scripts were not executed. | Define and validate the 24-entry palette contract before writing any output. |
| R-11 | Medium | Hypothesis | Macchiato Neovim overrides may be ignored because generated overrides remain under `mocha` while Macchiato is selected. | `themes/apply:55-64`; `themes/templates/nvim_colorscheme.lua:7-10,20-46` | Owner: repository maintainer. Blocker: verify with Catppuccin runtime. | Add a focused runtime check and correct only if confirmed. |
| R-12 | Medium | Confirmed | `brave` is launched with `--password-store=basic`, weakening normal desktop credential-store integration. | `zsh/aliases.zsh:67`; `hyprland/programs.lua:7` | Owner: system owner. Blocker: confirm compatibility requirement. | Remove unless a documented compatibility need outweighs credential-store protection. |
| R-13 | Medium | Confirmed | Shutdown and reboot keybindings execute without a configured confirmation step. | `hyprland/keybinds.lua:102-106` | Owner: system owner. Blocker: desired emergency-action ergonomics. | Add confirmation or move destructive bindings to a less accidental chord. |
| R-14 | Low | Confirmed | Documentation overstates theme coverage: it omits an available palette and claims GTK/Qt theming not implemented by the applier. | `README.md:121-129`; `themes/solitary-massif.conf:1-24`; `themes/apply:8-17,21-34,86-136` | Owner: repository maintainer. Blocker: intended supported integrations. | Correct documentation after deciding supported scope. |
| R-15 | Low | Confirmed | Declared Ranger submodule is absent from the inspected root and unused by the installer. | `.gitmodules:1-3`; `install.sh:245-435` | Owner: repository maintainer. Blocker: determine whether it is obsolete or uninitialized. | Confirm purpose; remove declaration or restore/use it intentionally. |
| R-16 | Low | Unknown | `themes/templates/__pycache__/` is present but not covered by the shown Python-cache ignore rule; tracking status was not inspected. | `themes/templates/`; `.gitignore:22-29` | Owner: repository maintainer. Blocker: inspect Git index/status without mutating it. | Remove generated cache if unintentional; add a scoped ignore rule if needed. |
| R-17 | Low | Hypothesis | Gap adjustment parsing can break after a Hyprland textual-output change. | `hyprland/scripts/adjust_gaps:14-25,31-34` | Owner: repository maintainer. Blocker: test against supported Hyprland versions. | Prefer a stable machine-readable interface when available; otherwise pin/document compatibility. |

## Prioritization

Address R-01 through R-06 before broadening features. R-09 blocks a reproducible fresh install. R-10 and R-11 require controlled verification before behavior changes. R-14 through R-16 are documentation/hygiene follow-up after the supported contract is decided.
