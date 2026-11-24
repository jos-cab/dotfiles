# Static audit of `install.sh`

## Scope and method

- Exclusive scope: `install.sh`; static review, without executing scripts or commands. Primary evidence: `install.sh:1-451`.
- It was verified that the repository declares the submodules `ranger/plugins/ranger_devicons` and `ananicy`; the installer initializes all declared submodules recursively if `.gitmodules` exists. Evidence: `.gitmodules:1-6`, `install.sh:154-158`.
- No audit was performed for the content, security, or compatibility of the linked configurations, packages, AUR sources, services, submodules, or external commands. The installer invokes or links them, but does not validate them. Evidence: `install.sh:119-132`, `install.sh:214-234`, `install.sh:250-254`.

## Facts: flow

1. Bash runs with `set -e`; unhandled failures terminate the process. Evidence: `install.sh:1`, `install.sh:7`.
2. Warns (without blocking) when `OSTYPE` does not start with `linux-gnu`. Evidence: `install.sh:28-33`.
3. Resolves `DOTFILES_DIR` to the physical directory of the script itself; fixes configuration under `$HOME/.config`. Evidence: `install.sh:148-149`.
4. If `.gitmodules` exists, runs `git -C "$DOTFILES_DIR" submodule update --init --recursive`; its failure is not recovered from. Evidence: `install.sh:154-158`, `install.sh:7`.
5. Aborts if `kitty/` and `hyprland/` are both missing at the same time; it does not require both nor the rest of the sources. Evidence: `install.sh:160-164`.
6. First prompt: backups. Enter or `y`/`yes` enables backups; `n`/`no`, any other input, disables backups. Evidence: `install.sh:166-184`.
7. Creates `$HOME/.config`, prompts for dependency installation, links any found configurations, optionally suggests `chsh`, then checks five expected symlinks. Evidence: `install.sh:191-243`, `install.sh:245-435`, `install.sh:439-450`.
8. `nullglob` removes unmatched patterns before the linking loops. Evidence: `install.sh:194`.

## Facts: functions, dependencies, and privileges

- `check_dependencies` only reports missing `hyprland`, `kitty`, `waybar`, `wofi`, `mako`, `zsh`, `starship`, `nvim`, and `fastfetch`; it does not abort or install them. Evidence: `install.sh:35-46`, `install.sh:243`.
- If installation is accepted and `pacman` exists, it runs `sudo pacman -S ... --noconfirm` with Arch packages; a failure is downgraded to a warning. Evidence: `install.sh:205-225`.
- After that attempt, it checks PipeWire status via `systemctl --user`; a non-active state only warns. Evidence: `install.sh:138-146`, `install.sh:225`.
- If `paru` or `yay` exists, it installs three AUR packages without confirmation; failures only warn. Evidence: `install.sh:227-237`.
- `configure_ananicy` only acts if `ananicy/` exists, `ananicy-cpp` is in `PATH`, and `sudo -n true` works; therefore it does not request a password for this path. Evidence: `install.sh:98-114`, `install.sh:245-258`.
- That path creates `/etc/ananicy.d` with mode `0755`, installs matching files with mode `0644`, copies `00-default` via `cp -a`, and enables/starts/restarts `ananicy-cpp.service`. Evidence: `install.sh:116-132`.
- `systemctl` failures for ananicy are handled with warnings; failures of `sudo install`, `sudo cp`, or directory creation are not. Evidence: `install.sh:117-132`, `install.sh:7`.
- The package path may request credentials via `sudo`; the ananicy path requires passwordless sudo. Evidence: `install.sh:111-114`, `install.sh:214-224`.
- If the user agrees to change shells, it obtains the `zsh` path via `command -v zsh` and runs `chsh -s`; failure only warns. Evidence: `install.sh:415-433`.

## Facts: filesystem and existing configuration

### Replacement rule

- `create_symlink(dest, source)` rejects empty arguments, creates the parent of `dest`, backs up or deletes the existing destination, then runs `ln -sf`. Evidence: `install.sh:69-94`.
- Treats an existing file, directory, valid symlink, or dangling symlink as existing via `-e || -L`. Evidence: `install.sh:54`, `install.sh:85`.
- With backups disabled, it recursively removes every existing destination via `rm -rf`, including directories and links. Evidence: `install.sh:85-89`.
- With backups enabled, it moves the destination to `DEST.bak`; if that exists, it tries `DEST.bak.1`, `.2`, etc. sequentially. Evidence: `install.sh:52-64`.
- Backups are per direct destination; there is no manifest, compression, retention policy, or restore operation. Evidence: `install.sh:52-65`, `install.sh:437-451`.
- `mkdir -p` of parent and container directories does not back up those containers. Evidence: `install.sh:79-80`, `install.sh:191-192`, `install.sh:247`, `install.sh:262`.

### Destinations it can modify

- Links each existing entry of `ananicy/` under `~/.config/ananicy/`; it can also modify `/etc/ananicy.d` and the service. Evidence: `install.sh:245-258`, `install.sh:98-135`.
- Links each existing entry of `hyprland/` under `~/.config/hypr/`. Evidence: `install.sh:260-271`.
- Links only regular files from `gtk-3.0/`, `gtk-4.0/`, `fastfetch/`, `kitty/`, and `wofi/` into their corresponding subdirectories. Evidence: `install.sh:273-284`, `install.sh:292-312`, `install.sh:374-383`.
- Links `imv/config`, `mako/config`, `zathura/zathurarc`; links `starship/starship.toml` to both `~/.config/starship/starship.toml` and `~/.config/starship.toml`. Evidence: `install.sh:286-290`, `install.sh:314-318`, `install.sh:338-347`, `install.sh:385-389`.
- Links entries of `nvim/` except one entry named exactly `docs`, under `~/.config/nvim/`. Evidence: `install.sh:320-336`.
- Links entries of `waybar/`; it splits `waybar/scripts/` and links its children individually. Evidence: `install.sh:349-372`.
- If `theme` is executable, links `~/.local/bin/dotfiles-theme`. Evidence: `install.sh:391-395`.
- In `zsh/`, links `zshrc` or `.zshrc` as `~/.zshrc`; links the remaining regular files under `~/.config/zsh/`. Evidence: `install.sh:397-413`.
- It does not link directories under GTK, fastfetch, kitty, wofi, or zsh because it filters with `-f`; it does link directories under ananicy, hyprland, nvim, and waybar. Evidence: `install.sh:250-254`, `install.sh:265-269`, `install.sh:277-281`, `install.sh:295-299`, `install.sh:306-310`, `install.sh:325-335`, `install.sh:354-369`, `install.sh:377-381`, `install.sh:401-412`.

## Facts: errors, interruptions, and idempotency

- `tput civis` and `tput cnorm` ignore errors; the three interactive reads have no shell-default value and no EOF handling. Evidence: `install.sh:170-174`, `install.sh:199-204`, `install.sh:420-423`.
- A failure of `read`, `mkdir`, `mv`, `rm`, `ln`, `git`, `sudo install`, or `sudo cp` can stop the process due to `set -e` when it occurs without explicit handling. Evidence: `install.sh:7`, `install.sh:63`, `install.sh:80`, `install.sh:88`, `install.sh:93`, `install.sh:157`, `install.sh:117-126`.
- Package failures, AUR, PipeWire state, ananicy service management, and `chsh` failures are explicitly downgraded to warnings; the flow continues. Evidence: `install.sh:141-145`, `install.sh:224`, `install.sh:231-233`, `install.sh:129-134`, `install.sh:428-431`.
- There is no `trap`, cleanup, transaction, or rollback on signal, EOF, or intermediate failure. Evidence: `install.sh:1-451`.
- A second execution re-processes each existing destination: it re-backs it up again if backups are enabled, or deletes and recreates it if backups are disabled. Evidence: `install.sh:82-93`, `install.sh:52-64`.
- The final verification only checks that five paths are symlinks; it does not verify destination, readability, other symlinks, packages, services, or `chsh`. Evidence: `install.sh:439-450`.

## Verified risks

1. **Destructive loss of existing configuration.** If the user responds `n`, provides an invalid input, or hits EOF not handled before the decision, `DO_BACKUPS=false`; every already-existing destination is removed with `rm -rf`. Evidence: `install.sh:175-184`, `install.sh:82-89`.
2. **Partial state without recovery.** The script replaces destinations one by one and can abort after prior modifications; it does not implement rollback. Evidence: `install.sh:7`, `install.sh:245-435`, `install.sh:1-451`.
3. **Persistent privileged modification.** With non-interactive sudo, it modifies `/etc/ananicy.d` and enables/starts/restarts a service. Evidence: `install.sh:111-132`.
4. **Non-interactive package installation.** Acceptance installs official packages and, if a helper exists, installs AUR packages with `--noconfirm`. Evidence: `install.sh:214-234`.
5. **Manual restoration.** Backups are created but not automatically restored, and it does not record which destinations were replaced. Evidence: `install.sh:52-65`, `install.sh:437-451`.

## Potential risks / unknowns

- **Non-interactive input.** Hypothesis: EOF in any of the `read` calls can cut the installation due to `set -e` and, if it happens after hiding the cursor, prevent `tput cnorm`. Requires controlled testing; relevant code: `install.sh:7`, `install.sh:170-174`, `install.sh:199-204`, `install.sh:420-423`.
- **Semantics of `ln -sf` and anomalous pre-existing paths.** Unknown: effective behavior with permissions, mount points, parents that are symlinks, or immutable attributes; the script does not pre-inspect those conditions. Evidence: `install.sh:79-93`.
- **Source integrity.** Unknown: linked files and the content of submodules are not validated via hash, signature, or review. Evidence: `install.sh:154-158`, `install.sh:250-254`.
- **Package/service compatibility.** Unknown: availability of pacman/AUR names, compatibility with the Arch version, successful boot, and validity of ananicy rules. Evidence: `install.sh:214-234`, `install.sh:119-132`.

## Observed decisions

- Linux is the target that is warned about; it is not a hard requirement. Evidence: `install.sh:28-33`.
- Backups are effectively opt-in by default: Enter enables them, but unrecognized inputs disable them. Evidence: `install.sh:168-184`.
- Dependency installation is opt-in; default is off. Evidence: `install.sh:196-210`.
- Privileged ananicy configuration is omitted (no password prompt) unless passwordless sudo is already available. Evidence: `install.sh:106-114`.
- The shell is changed only after explicit consent and only if `$SHELL` does not contain `zsh`. Evidence: `install.sh:415-433`.

## Not inspected sections

- Content and effects of configurations, linked scripts, `theme`, ananicy rules, service files, and submodules.
- Availability, provenance, licenses, or security of pacman/AUR packages.
- Real system state, `$HOME`, permissions, sudoers, TTY, networking, systemd, PipeWire, and the current shell.
- Dynamic execution, interruption tests, real idempotency, and restore behavior of backups.
