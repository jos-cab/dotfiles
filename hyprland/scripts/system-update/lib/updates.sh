#!/usr/bin/env bash
# Package and tool update routines

update_reflector() {
    step "Mirrors — reflector"
    if ! need_cmd reflector; then
        skip "reflector not installed"
        record "reflector" "SKIP" "not installed"
        return 0
    fi
    if ! sudo_run cp -f /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak; then
        fail "Could not backup mirrorlist"
        record "reflector" "FAIL" "backup failed"
        return 1
    fi
    if sudo_run reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist; then
        ok "Mirrorlist updated (backup saved to /etc/pacman.d/mirrorlist.bak)"
        record "reflector" "OK"
    else
        sudo_run cp -f /etc/pacman.d/mirrorlist.bak /etc/pacman.d/mirrorlist || true
        fail "reflector failed"
        record "reflector" "FAIL"
        return 1
    fi
}

repair_pacman_keys() {
    step "Keys — pacman-key"
    if ! need_cmd pacman-key; then
        skip "pacman-key not found"
        record "pacman_keys" "SKIP"
        return 0
    fi
    if sudo_run pacman-key --init && sudo_run pacman-key --populate archlinux; then
        ok "pacman keys initialized and populated"
        record "pacman_keys" "OK"
    else
        fail "Could not repair pacman keys"
        record "pacman_keys" "FAIL"
        return 1
    fi
}

update_system() {
    step "System — paru -Syu"
    if ! need_cmd paru; then
        skip "paru not installed"
        record "paru" "SKIP" "not installed"
        return 0
    fi
    if paru -Syu --noconfirm --skipreview; then
        ok "paru -Syu completed"
        record "paru" "OK"
    else
        fail "paru -Syu failed"
        record "paru" "FAIL"
        return 1
    fi
}

update_npm() {
    step "npm — global packages"
    if ! need_cmd npm; then
        skip "npm not installed"
        record "npm" "SKIP" "not installed"
        return 0
    fi
    local prefix res=0
    prefix="$(npm config get prefix 2>/dev/null || echo "")"
    case "$prefix" in
        "$HOME"|"$HOME"/*) npm -g update || res=$? ;;
        *)
            skip "npm global prefix (${prefix:-unknown}) is system-wide and pacman-owned — run: npm config set prefix ~/.local"
            record "npm" "SKIP" "system-wide prefix"
            return 0
            ;;
    esac
    if [[ $res -eq 0 ]]; then
        ok "npm global update OK"
        record "npm" "OK"
    else
        fail "npm update failed"
        record "npm" "FAIL"
        return 1
    fi
}

update_uv_tools() {
    step "uv — tool upgrade --all"
    if ! need_cmd uv; then
        skip "uv not installed"
        record "uv" "SKIP" "not installed"
        return 0
    fi
    if [[ -z "$(uv tool list 2>/dev/null)" ]]; then
        skip "no uv tools installed"
        record "uv" "SKIP" "no tools"
        return 0
    fi
    if uv tool upgrade --all; then
        ok "uv tools updated"
        record "uv" "OK"
    else
        fail "uv tool upgrade failed"
        record "uv" "FAIL"
        return 1
    fi
}

update_pipx() {
    step "pipx — upgrade-all"
    if ! need_cmd pipx; then
        skip "pipx not installed"
        record "pipx" "SKIP" "not installed"
        return 0
    fi
    if [[ -z "$(pipx list --short 2>/dev/null)" ]]; then
        skip "no pipx packages installed"
        record "pipx" "SKIP" "no packages"
        return 0
    fi
    if pipx upgrade-all; then
        ok "pipx upgrade-all OK"
        record "pipx" "OK"
    else
        fail "pipx upgrade-all failed"
        record "pipx" "FAIL"
        return 1
    fi
}

run_updates() {
    section "UPDATES"
    update_system || true
    update_npm || true
    update_uv_tools || true
    update_pipx || true
}

run_devtools() {
    section "DEV TOOLS"
    update_uv_tools || true
    update_pipx || true
}
