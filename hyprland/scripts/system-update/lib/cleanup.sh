#!/usr/bin/env bash
# Cache and storage cleanup modules

show_cache_usage() {
    step "Caches — disk usage"
    if [[ -d /var/cache/pacman/pkg ]]; then
        local sz
        sz=$(du -sh /var/cache/pacman/pkg 2>/dev/null | awk '{print $1}')
        log "    pacman cache: ${C_BOLD}${sz:-?}${C_RESET}  (/var/cache/pacman/pkg)"
    else
        log "    pacman cache: not found"
    fi
    local paru_cache="$HOME/.cache/paru"
    if [[ -d "$paru_cache" ]]; then
        local sz2
        sz2=$(du -sh "$paru_cache" 2>/dev/null | awk '{print $1}')
        log "    paru cache:   ${C_BOLD}${sz2:-?}${C_RESET}  ($paru_cache)"
        if [[ -d "$paru_cache/clone" ]]; then
            local szc
            szc=$(du -sh "$paru_cache/clone" 2>/dev/null | awk '{print $1}')
            log "      └─ clone:   ${szc:-?}"
        fi
    fi
    if need_cmd journalctl; then
        local jsz
        jsz=$(journalctl --disk-usage 2>/dev/null | grep -oE "[0-9.]+[a-zA-Z]+" | head -1 || echo "?")
        log "    journal:      ${C_BOLD}${jsz:-?}${C_RESET}"
    fi
    record "cache_usage" "OK"
}

cleanup_pacman_cache() {
    step "Cleanup — pacman cache (paccache -rk$PACMAN_CACHE_KEEP)"
    if ! need_cmd paccache; then
        skip "paccache not installed (pacman-contrib)"
        record "pacman_cache" "SKIP" "paccache not installed"
        return 0
    fi
    if ! sudo -n true 2>/dev/null; then
        skip "paccache skipped — sudo not available"
        record "pacman_cache" "SKIP" "no sudo"
        return 0
    fi
    local before after
    before=$(du -sh /var/cache/pacman/pkg 2>/dev/null | awk '{print $1}')
    before="${before:-?}"
    info "Size before: $before"
    if sudo paccache -rk"$PACMAN_CACHE_KEEP" && sudo paccache -ruk0; then
        after=$(du -sh /var/cache/pacman/pkg 2>/dev/null | awk '{print $1}')
        after="${after:-?}"
        ok "Cache cleaned ($before → $after)"
        record "pacman_cache" "OK" "$before → $after"
    else
        fail "paccache failed"
        record "pacman_cache" "FAIL"
        return 1
    fi
}

cleanup_paru_cache() {
    step "Cleanup — paru clone cache"
    local clone_dir="$HOME/.cache/paru/clone"
    if [[ -d "$clone_dir" ]]; then
        local before after
        before=$(du -sh "$clone_dir" 2>/dev/null | awk '{print $1}')
        find "$clone_dir" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null
        after=$(du -sh "$clone_dir" 2>/dev/null | awk '{print $1}')
        ok "paru clones cleaned (${before:-?} → ${after:-?})"
        record "paru_cache" "OK" "${before:-?} → ${after:-?}"
    else
        skip "no paru clone directory"
        record "paru_cache" "SKIP" "no clone dir"
    fi
}

check_orphans() {
    step "Cleanup — orphan packages (pacman -Qtd)"
    local orphans
    orphans=$(pacman -Qtdq 2>/dev/null || true)
    if [[ -z "$orphans" ]]; then
        ok "No orphan packages"
        record "orphans" "OK"
        return 0
    fi
    local count
    count=$(echo "$orphans" | wc -l)
    warn_msg "$count orphan package(s) detected:"
    while IFS= read -r p; do log "    $p"; done <<< "$orphans"
    record "orphans" "WARN" "$count orphan(s)"

    # Auto-confirmed (AUTO_CONFIRM=1)
    if confirm "Remove orphans now? (pacman -Rns)" "N"; then
        if ! sudo -n true 2>/dev/null; then
            fail "Could not remove orphans — sudo not available"
            record "orphans" "FAIL" "no sudo"
            return 1
        fi
        local -a pkgs
        mapfile -t pkgs <<< "$orphans"
        if sudo pacman -Rns --noconfirm "${pkgs[@]}"; then
            ok "Orphans removed"
            record "orphans" "OK" "removed"
        else
            warn_msg "Orphan removal cancelled or failed"
            record "orphans" "WARN" "removal cancelled or failed"
        fi
    else
        info "Orphans preserved"
    fi
}

vacuum_journal() {
    step "Cleanup — journal (vacuum-time=$JOURNAL_KEEP)"
    if ! need_cmd journalctl; then
        skip "journalctl not available"
        record "journal" "SKIP"
        return 0
    fi
    if ! sudo -n true 2>/dev/null; then
        skip "journal vacuum skipped — sudo not available"
        record "journal" "SKIP" "no sudo"
        return 0
    fi
    local before after
    before=$(journalctl --disk-usage 2>/dev/null | grep -oE "[0-9.]+[a-zA-Z]+" | head -1)
    before="${before:-?}"
    info "Size before: $before"
    if sudo journalctl --vacuum-time="$JOURNAL_KEEP"; then
        after=$(journalctl --disk-usage 2>/dev/null | grep -oE "[0-9.]+[a-zA-Z]+" | head -1)
        after="${after:-?}"
        ok "Journal vacuum OK ($before → $after)"
        record "journal" "OK" "$before → $after"
    else
        fail "journal vacuum failed"
        record "journal" "FAIL"
        return 1
    fi
}

run_cleanup() {
    section "CLEANUP"
    show_cache_usage || true
    if confirm "Clean pacman cache (paccache)?" "N"; then
        cleanup_pacman_cache || true
    else
        skip "pacman cache preserved"
        record "pacman_cache" "SKIP" "user skipped"
    fi
    cleanup_paru_cache || true
    check_orphans || true
    if confirm "Vacuum journal (--vacuum-time=$JOURNAL_KEEP)?" "N"; then
        vacuum_journal || true
    else
        skip "journal preserved"
        record "journal" "SKIP" "user skipped"
    fi
}
