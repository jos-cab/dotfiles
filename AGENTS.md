# Instructions for agents

## Scope

- Personal dotfiles repository for Arch Linux + Hyprland.
- Configuration is installed primarily via symbolic links from `install.sh`.
- Consult `README.md` for usage and `docs/development/commands.md` for available validations.
- Rules in `.opencode/agents/` take precedence for specialized agents; do not duplicate them here.

## Security and user files

- Never read secrets, credentials, keys, or ignored local files. Respect `opencode.jsonc` denials.
- Treat `$HOME`, `~/.config`, `/etc`, services, packages, and application preferences as user or system state.
- Do not run `install.sh`, `theme`, `themes/apply`, updaters, or scripts that may modify the system, configurations, packages, services, or applications, unless explicitly requested by the user.
- Do not use `sudo`, install packages, change the login shell, manage services, or modify submodules without explicit authorization.
- Before changing paths that might replace files, links, or directories, inspect effects, destinations, and existing recovery. Do not delete unrequested files.

## Inspection and changes

- Review related files, documentation, and `git diff`/`git status` before editing. Preserve non-owned changes.
- Keep changes minimal, localized, and consistent with existing style. Do not modify functionality outside the requested scope.
- Distinguish confirmed facts from hypotheses. Do not document unverified behavior.
- For installers, themes, maintenance scripts, system configurations, or privileged changes: static review first; require explicit authorization before any mutating execution.
- `themes/apply` modifies versioned files and can modify external state; do not run it during development tasks without explicit authorization.

## Validation

- Run only non-mutating checks relevant to the change.
- Use commands documented in `docs/development/commands.md` when applicable.
- For changes to `install.sh`, run `bash tests/install_safety_test.sh` in addition to applicable syntactic checks.
- Report executed and omitted validations with reasons. Do not claim validation of unexecuted behavior.

## Git and commits

- Inspect state before and after work.
- Do not create commits, change branches, rewrite history, push, reset, clean, or modify submodules unless explicitly requested.
- Do not include pre-existing user changes in your own modifications.

## Documentation

- Update documentation only if the change alters documented behavior, usage, requirements, or validation.
- Avoid duplication: link or refer to existing documentation when sufficient.
- Maintain `docs/discovery/` as static evidence: note coverage limits and do not present hypotheses as facts.
