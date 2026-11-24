# Improvement roadmap

## Scope

Planning only. No code changes, refactors, or script execution are authorized by this discovery. Tasks are unique, ordered by dependency, and traceable to source evidence.

## Ordered backlog

| ID | Priority | Task | Depends on | Owner | Decision / blocker | Completion evidence |
|---|---|---|---|---|---|---|
| RM-01 | P0 | Define installer overwrite, invalid-input, non-interactive, backup retention, and restore contract. | — | Repository maintainer + system owner | Owner approval required; current fallback deletes destinations. `install.sh:52-65,82-93,166-184` | Approved written contract covering files, directories, links, interruption, and restore. |
| RM-02 | P0 | Design a recoverable installer mutation boundary from the approved contract; include links, package/service steps, and interruption handling. | RM-01 | Repository maintainer | Rollback scope unresolved. Current run is non-transactional. `install.sh:7,58,245-435`; `install.sh:1-451` | Reviewed design plus controlled test plan demonstrating failure/interruption recovery. |
| RM-03 | P0 | Implement and test the approved safe installer behavior. | RM-02 | Repository maintainer | Do not change behavior before RM-01/RM-02 approval. | Tests cover invalid input, existing file/directory/link, failure mid-run, and restore. |
| RM-04 | P0 | Audit Ananicy submodule revision/rules; decide privileged setup ownership, consent, and reversal procedure. | — | System owner | No rule audit was performed. `install.sh:98-135,245-258`; `.gitmodules:4-6` | Approved audit record, pinned/reviewed revision policy, documented service reversal. |
| RM-05 | P0 | Define theme generated-file, backup/restore, and external-integration contract. | — | Repository maintainer + system owner | `apply` mutates repository and external state without restore. `themes/apply:42-74,86-136`; `theme:1-26` | Approved contract distinguishing internal outputs, BetterDiscord, Spicetify, Brave, and VS Code. |
| RM-06 | P1 | Specify and validate the 24-entry palette schema before output writes. | RM-05 | Repository maintainer | Malformed-palette runtime behavior unverified. `themes/apply:36-40,48-50,53,59-64`; `themes/catppuccin-mocha.conf:1-24` | Negative fixtures reject short, invalid, and reordered/invalid-key input before mutation. |
| RM-07 | P1 | Add preview/backup/restore behavior for approved theme destinations. | RM-05, RM-06 | Repository maintainer | Must not silently redefine generated-file policy. `themes/apply:42-74,86-136` | Controlled test demonstrates preview, cancellation, successful restore, and Spicetify handling. |
| RM-08 | P1 | Verify Neovim Macchiato override behavior; correct only if runtime evidence confirms failure. | RM-06 | Repository maintainer | Requires controlled Neovim/Catppuccin runtime. `themes/apply:55-64`; `themes/templates/nvim_colorscheme.lua:7-10,20-46` | Reproducible check records effective Macchiato colors and resulting disposition. |
| RM-09 | P0 | Define maintenance consent policy; then remove unattended approval from AUR updates and destructive cleanup where policy requires. | — | System owner | Existing auto-confirm policy intentionally broad. `hyprland/scripts/system-update/lib/common.sh:15,145-163`; `hyprland/scripts/system-update/lib/updates.sh:45-58`; `hyprland/scripts/system-update/lib/cleanup.sh:91-105` | Approved policy plus controlled checks for AUR review, orphan removal, cache cleanup, and logs. |
| RM-10 | P0 | Define remote-bootstrap trust policy; pin or otherwise verify Zinit/plugins according to it. | — | Repository maintainer | Select revision update/verification owner first. `zsh/zinit.zsh:5-23`; `zsh/plugins.zsh:4-12` | Fresh-shell test uses approved immutable/verified sources. |
| RM-11 | P1 | Resolve `local.lua` precedence discrepancy and verify one local override. | — | Repository maintainer | Choose load-order versus documentation correction. `hyprland/local.lua.example:8`; `hyprland/hyprland.lua:31-44` | Test and documentation agree on effective precedence. |
| RM-12 | P1 | Build a command-to-package/provision matrix for all autostart and capture dependencies; resolve omitted dependencies. | — | Repository maintainer | Confirm package/source for each command, especially `gnome-keyring-daemon`, `easyeffects`, `headroom`, `9router`, and `grimblast`. `hyprland/autostart.lua:6,17,26-27`; `hyprland/scripts/capture-selection:23-34`; `install.sh:214-237` | Fresh-install checklist detects/provisions every required command with documented optionality. |
| RM-13 | P2 | Decide BetterDiscord remote-CSS policy; make integration opt-in, pin, or vendor according to approval. | RM-05 | System owner | Third-party runtime import requires trust/licensing decision. `themes/templates/betterdiscord.theme.css:7-13`; `themes/apply:87-103` | Approved dependency record and test of opted-in behavior. |
| RM-14 | P2 | Correct supported-theme documentation after RM-05 and RM-12 establish actual scope. | RM-05, RM-12 | Repository maintainer | Do not document unimplemented GTK/Qt behavior. `README.md:121-129`; `themes/solitary-massif.conf:1-24`; `themes/apply:8-17,21-34,86-136` | README matches enumerated palettes, outputs, dependencies, reload behavior, and restore path. |
| RM-15 | P2 | Resolve Ranger submodule purpose and generated Python-cache status. | — | Repository maintainer | Determine obsolete/uninitialized state and Git tracking without mutation. `.gitmodules:1-3`; `install.sh:245-435`; `themes/templates/`; `.gitignore:22-29` | Recorded disposition: retain/use, restore, or remove Ranger; cache tracking/ignore policy verified. |
| RM-16 | P2 | Define supported runtime versions and add non-mutating validation coverage for installer, themes, and Hyprland scripts. | RM-03, RM-07, RM-08, RM-11, RM-12 | Repository maintainer | Runtime compatibility is currently unverified. `docs/development/commands.md:1-60`; `hyprland/scripts/adjust_gaps:14-25,31-34`; `docs/discovery/03-system-configurations.md:91` | Version matrix plus repeatable checks for declared supported environments. |

## Gates

- **Release safety gate:** RM-01–RM-05, RM-09, and RM-10 approved before presenting installer/theme/update behavior as safe for new machines.
- **Fresh-install gate:** RM-12 complete before claiming the installer provisions the documented desktop session.
- **Documentation gate:** RM-14 follows implementation and verification; it must not mask unresolved behavior.

## Deferred

No CI or broad refactor is scheduled. Add automation only after RM-16 defines stable supported versions and repeatable checks.
