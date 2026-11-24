# Architecture decisions

## Scope

Observed decisions only. This is not a refactor proposal. Evidence is static and uses `file:line`; unverified consequences are marked accordingly.

| ID | Decision | Status | Evidence | Consequences | Owner decision / blocker |
|---|---|---|---|---|---|
| AD-01 | Target Arch Linux, Wayland, and Hyprland; Linux is warned about rather than enforced by the installer. | Confirmed | `README.md:3,11-13,30-43`; `install.sh:28-33` | Broader invocation is possible, but unsupported OS execution can proceed. | Owner: maintainer. Decide whether support is Arch-only or merely best-effort. |
| AD-02 | Use one Bash installer to initialize submodules, link configuration into `$HOME`, optionally install packages, configure Ananicy, and offer Zsh as login shell. | Confirmed | `install.sh:148-158`; `install.sh:191-243`; `install.sh:245-435`; `install.sh:415-433` | Central entry point; filesystem, package, privileged-service, and shell mutations share one run. | Owner: maintainer. R-01/R-02/R-03 block retaining current mutation semantics. |
| AD-03 | Preserve existing destinations only when the user opts into backups; otherwise replace destinations recursively. | Confirmed | `install.sh:52-65`; `install.sh:82-93`; `install.sh:166-184` | Fast replacement; destructive fallback for invalid input and no automated restore. | Owner: maintainer. Must define overwrite/default/restore policy. |
| AD-04 | Treat Ananicy as both user-linked configuration and optional system service configuration, only when passwordless sudo is already available. | Confirmed | `install.sh:98-135`; `install.sh:245-258` | Avoids password prompt; can silently omit system setup or persist privileged state. | Owner: system owner. Audit submodule and approve service lifecycle. |
| AD-05 | Make Hyprland modular Lua loaded in a fixed order; load optional `local.lua` before shared modules. | Confirmed | `hyprland/hyprland.lua:22-44` | Modules are predictable; local override claim conflicts with actual precedence. | Owner: maintainer. Blocker: choose intended local precedence (R-08). |
| AD-06 | Keep machine-specific secrets/settings in ignored local files. | Confirmed | `hyprland/local.lua.example:1-10`; `zsh/zshrc:15-33`; `.gitignore:1-7` | Prevents committing local values; secret exposure through child environment remains unassessed. | Owner: system owner. Define secret-handling boundary for `NINEROUTER_KEY`. |
| AD-07 | Use a palette plus templates to generate theme-sensitive configuration directly in the repository, allowing installed symlinks to reflect changes. | Confirmed | `themes/apply:8-17`; `themes/apply:42-74`; `install.sh:260-389` | One command updates linked consumers; source tree becomes mutable generated state without theme-specific restoration. | Owner: maintainer. R-06 blocks expansion until backup/restore and generated-file policy are chosen. |
| AD-08 | Use a fixed 24-position palette contract based on Catppuccin Mocha replacement values. | Confirmed | `themes/apply:36-40`; `themes/catppuccin-mocha.conf:1-24` | Simple substitutions; names are ignored and input format is unvalidated. | Owner: maintainer. Blocker: validate contract and test malformed palette behavior (R-10). |
| AD-09 | Integrate external themes opportunistically through detected paths/tools, except BetterDiscord output is always created when its template exists. | Confirmed | `themes/apply:86-136` | Convenience; external state varies by host, and BetterDiscord adds remote CSS. | Owner: system owner. Decide opt-in scope and remote-CSS policy (R-06/R-07). |
| AD-10 | Autostart desktop services and personal tools directly from Hyprland. | Confirmed | `hyprland/autostart.lua:4-28` | Session behavior stays close to compositor config; undeclared commands reduce fresh-install reproducibility. | Owner: maintainer. Blocker: source/package each invoked command (R-09). |
| AD-11 | Run system maintenance through a Hyprland-launched modular updater with automatic confirmation, AUR updates, cleanup, logs, and locking. | Confirmed | `hyprland/scripts/update-packages:5-18`; `hyprland/scripts/system-update/system-update.sh:22-30,77-102`; `hyprland/scripts/system-update/lib/common.sh:15,145-163` | Streamlined maintenance; destructive or supply-chain-sensitive actions proceed unattended. | Owner: system owner. R-04 blocks unattended destructive maintenance policy. |
| AD-12 | Bootstrap Zinit and remote Zsh plugins on first shell startup. | Confirmed | `zsh/zinit.zsh:5-23`; `zsh/plugins.zsh:4-12` | Minimal initial setup; first use requires network and executes unpinned remote code. | Owner: maintainer. R-05 blocks security hardening decision. |
| AD-13 | Bootstrap Neovim Lazy.nvim, then use `lazy-lock.json` for plugin state. | Confirmed | `nvim/lua/config/lazy.lua:1-37`; `nvim/lazy-lock.json:1-33` | Subsequent plugin state is recorded; initial Lazy.nvim clone is not SHA-pinned. | Owner: maintainer. Decide whether bootstrap integrity needs pinning. |
| AD-14 | Keep validation as documented local syntax commands rather than versioned CI or functional tests. | Confirmed | `docs/development/commands.md:1-60`; `docs/discovery/03-system-configurations.md:91` | Low setup cost; runtime, interruption, and integration outcomes remain unverified. | Owner: maintainer. Blocker: define supported environments before adding automation. |

## Open decisions

1. Destructive-install and restoration contract: blocks R-01, R-02, and roadmap tasks RM-01–RM-03.
2. Privileged Ananicy ownership and audit boundary: blocks R-03 and RM-04.
3. Theme-generated-file and external-integration contract: blocks R-06, R-07, R-10, R-11 and RM-05–RM-08.
4. Update automation consent policy: blocks R-04 and RM-09.
5. Remote bootstrap trust policy: blocks R-05 and RM-10.
6. Fresh-install dependency contract: blocks R-09 and RM-12.
