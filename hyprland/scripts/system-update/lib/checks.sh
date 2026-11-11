#!/usr/bin/env bash
# Pre-flight and post-flight health checks for Arch Linux
# shellcheck disable=SC2001 # Multiline indentation via sed stream

# ─────────────────────────────────────────────
# Pre-flight Checks
# ─────────────────────────────────────────────

check_disk_space() {
    step "Pre-flight — disk space"
    local failed=0 warned=0 seen_devs=()
    for mnt in "/" "/home" "/boot" "/efi"; do
        [[ -d "$mnt" ]] || continue
        local dev line use_perc avail
        dev=$(df -P "$mnt" 2>/dev/null | awk 'NR==2 {print $1}')
        [[ -z "$dev" ]] && continue
        if [[ " ${seen_devs[*]:-} " == *" $dev "* ]]; then
            continue
        fi
        seen_devs+=("$dev")

        line=$(df -hP "$mnt" 2>/dev/null | awk 'NR==2')
        [[ -z "$line" ]] && continue
        use_perc=$(awk '{print $5}' <<< "$line" | tr -d '%')
        [[ "$use_perc" =~ ^[0-9]+$ ]] || continue
        avail=$(awk '{print $4}' <<< "$line")

        if [[ "$use_perc" -ge "$DISK_CRIT_THRESHOLD" && "$mnt" != "/efi" ]]; then
            fail "$mnt ($dev) at ${use_perc}% (avail: $avail) — CRITICAL"
            failed=1
        elif [[ "$use_perc" -ge "$DISK_WARN_THRESHOLD" ]]; then
            warn_msg "$mnt ($dev) at ${use_perc}% (avail: $avail) — low space"
            warned=1
        else
            ok "$mnt ($dev) ${use_perc}% used (avail: $avail)"
        fi
        log_plain "    $line"
    done
    if (( failed )); then
        record "disk" "FAIL" "critical space (>=${DISK_CRIT_THRESHOLD}%)"
        return 1
    elif (( warned )); then
        record "disk" "WARN" "low space (>=${DISK_WARN_THRESHOLD}%)"
    else
        record "disk" "OK"
    fi
}

check_pacman_lock() {
    step "Pre-flight — pacman database lock"
    local lock="/var/lib/pacman/db.lck"
    if [[ ! -e "$lock" ]]; then
        ok "No pacman database lock"
        record "pacman_lock" "OK"
        return 0
    fi
    local holder=""
    if need_cmd fuser; then
        if sudo -n true 2>/dev/null; then
            holder=$(sudo -n fuser "$lock" 2>/dev/null || true)
        else
            holder=$(fuser "$lock" 2>/dev/null || true)
        fi
    fi
    if pgrep -x -u root pacman &>/dev/null || pgrep -x paru &>/dev/null || [[ -n "$holder" ]]; then
        local pids
        pids="$(pgrep -d, -x pacman 2>/dev/null || pgrep -d, -x paru 2>/dev/null || echo "$holder")"
        fail "Pacman database locked by active process (PID: ${pids:-unknown})"
        record "pacman_lock" "FAIL" "active lock"
        return 1
    else
        warn_msg "Stale pacman database lock detected: $lock"
        if confirm "Remove stale lock? (sudo rm -f $lock)" "N" \
            && sudo -n true 2>/dev/null && sudo rm -f "$lock"; then
            ok "Stale lock removed"
            record "pacman_lock" "OK" "stale lock removed"
            return 0
        fi
        fail "Stale lock still present — pacman/paru will refuse to run"
        record "pacman_lock" "FAIL" "stale lock"
        return 1
    fi
}

PENDING_REPO_UPDATES=""
PENDING_AUR_UPDATES=""
PENDING_CHECK_ERR=0

fetch_pending_updates() {
    PENDING_REPO_UPDATES=""
    PENDING_AUR_UPDATES=""
    PENDING_CHECK_ERR=0
    if need_cmd checkupdates; then
        local rc=0
        PENDING_REPO_UPDATES=$(checkupdates 2>/dev/null) || rc=$?
        # checkupdates: 0 = hay updates, 2 = no hay, otro = error
        if [[ $rc -ne 0 && $rc -ne 2 ]]; then
            PENDING_CHECK_ERR=1
            PENDING_REPO_UPDATES=""
        fi
    fi
    if need_cmd paru; then
        # paru -Qua sale con 1 cuando no hay nada: ignorar rc
        PENDING_AUR_UPDATES=$(paru -Qua 2>/dev/null || true)
    fi
}

count_pending_updates() {
    fetch_pending_updates
    local repo_count=0 aur_count=0
    [[ -n "$PENDING_REPO_UPDATES" ]] && repo_count=$(wc -l <<< "$PENDING_REPO_UPDATES")
    [[ -n "$PENDING_AUR_UPDATES" ]] && aur_count=$(wc -l <<< "$PENDING_AUR_UPDATES")
    local total=$(( repo_count + aur_count ))
    if [[ $PENDING_CHECK_ERR -eq 1 && $total -eq 0 ]]; then
        echo "?"
    else
        echo "$total"
    fi
}

check_pending_updates() {
    step "Pre-flight — pending updates"
    fetch_pending_updates
    local repo_count=0 aur_count=0
    [[ -n "$PENDING_REPO_UPDATES" ]] && repo_count=$(wc -l <<< "$PENDING_REPO_UPDATES")
    [[ -n "$PENDING_AUR_UPDATES" ]] && aur_count=$(wc -l <<< "$PENDING_AUR_UPDATES")

    local total=$(( repo_count + aur_count ))
    if [[ $PENDING_CHECK_ERR -eq 1 ]]; then
        warn_msg "Could not check repository updates (network or checkupdates error)"
        record "pending_before" "WARN" "could not check repo updates"
        return 0
    fi

    if [[ $total -eq 0 ]]; then
        ok "No pending updates"
        record "pending_before" "OK" "system up to date"
        return 0
    fi

    info "$repo_count repo update(s), $aur_count AUR update(s) available"
    if [[ -n "$PENDING_REPO_UPDATES" ]]; then
        log_plain "Repo updates:"
        sed 's/^/    /' <<< "$PENDING_REPO_UPDATES" | log_block
    fi
    if [[ -n "$PENDING_AUR_UPDATES" ]]; then
        log_plain "AUR updates:"
        sed 's/^/    /' <<< "$PENDING_AUR_UPDATES" | log_block
    fi
    record "pending_before" "INFO" "$total pending before update"
}

run_preflight() {
    section "PRE-FLIGHT CHECKS"
    check_pacman_lock || return 1
    if ! check_disk_space; then
        fail "Disk space critical — aborting before updating"
        return 1
    fi
    check_pending_updates
}

# ─────────────────────────────────────────────
# Post-flight Checks
# ─────────────────────────────────────────────

check_failed_services() {
    step "Health — failed systemd units"
    if ! need_cmd systemctl; then
        skip "systemctl not found"
        record "services" "SKIP"
        return 0
    fi
    local failed
    failed=$(systemctl --failed --no-legend --plain 2>/dev/null || true)
    if [[ -z "$failed" ]]; then
        ok "No failed systemd units"
        record "services" "OK"
        return 0
    fi
    warn_msg "Failed systemd units detected:"
    while IFS= read -r line; do log "    $line"; done <<< "$failed"
    record "services" "WARN" "failed units detected"
}

check_failed_user_services() {
    step "Health — failed user systemd units"
    if ! need_cmd systemctl || ! systemctl --user show-environment &>/dev/null; then
        skip "user systemd manager unavailable"
        record "user_services" "SKIP"
        return 0
    fi
    local failed
    failed=$(systemctl --user --failed --no-legend --plain 2>/dev/null || true)
    if [[ -z "$failed" ]]; then
        ok "No failed user systemd units"
        record "user_services" "OK"
        return 0
    fi
    warn_msg "Failed user systemd units detected:"
    while IFS= read -r line; do log "    $line"; done <<< "$failed"
    record "user_services" "WARN" "failed user units"
}

check_package_integrity() {
    step "Health — package integrity (pacman -Qk)"
    if ! need_cmd pacman; then
        skip "pacman not found"
        record "integrity" "SKIP"
        return 0
    fi
    local cmd=(env LC_ALL=C pacman -Qk) privileged=0
    if sudo -n true 2>/dev/null; then
        cmd=(sudo "${cmd[@]}")
        privileged=1
    fi
    local out
    out=$("${cmd[@]}" 2>&1 | grep -oE 'warning: .+\(No such file or directory\)' || true)

    if [[ -n "$out" ]] && need_cmd pacman-conf; then
        local -a noext=()
        mapfile -t noext < <(pacman-conf NoExtract 2>/dev/null | grep . || true)
        if [[ ${#noext[@]} -gt 0 ]]; then
            local p re_parts=()
            for p in "${noext[@]}"; do
                p="${p#/}"
                p="$(sed -E 's/[][\.^$+?(){}|]/\\&/g' <<< "$p")"
                p="${p//\*/.*}"
                re_parts+=("$p")
            done
            local re
            re="$(IFS='|'; echo "${re_parts[*]}")"
            out="$(grep -Ev ": /(${re}) \(No such file" <<< "$out" || true)"
        fi
    fi

    if [[ -n "$out" ]]; then
        warn_msg "Missing files detected (see log)"
        sed 's/^/    /' <<< "$out" | log_block
        head -n 10 <<< "$out" | while IFS= read -r l; do log "    $l"; done
        record "integrity" "WARN" "missing files detected"
    elif [[ $privileged -eq 0 ]]; then
        ok "Integrity OK (unprivileged run: unreadable files not verified)"
        record "integrity" "OK" "unprivileged"
    else
        ok "Integrity OK"
        record "integrity" "OK"
    fi
}

check_pacnew() {
    step "Health — .pacnew / .pacsave"
    local files=""
    if need_cmd pacdiff; then
        files=$(pacdiff -o 2>/dev/null || true)
    else
        files=$(find /etc -name "*.pacnew" -o -name "*.pacsave" 2>/dev/null || true)
    fi
    if [[ -z "$files" ]]; then
        ok "No pending .pacnew/.pacsave files"
        record "pacnew" "OK"
        return 0
    fi
    local count
    count=$(echo "$files" | wc -l)
    warn_msg "$count file(s) require attention:"
    echo "$files" | while read -r f; do log "    ${C_YELLOW}[pacnew]${C_RESET} $f"; done
    record "pacnew" "WARN" "$count file(s)"
    info "Review manually: sudo pacdiff"
}

check_foreign_packages() {
    step "Health — foreign packages (AUR/manual)"
    if ! need_cmd pacman; then
        skip "pacman not found"
        record "foreign" "SKIP"
        return 0
    fi
    local packages count
    packages=$(pacman -Qmq 2>/dev/null || true)
    if [[ -z "$packages" ]]; then
        ok "No foreign packages"
        record "foreign" "OK"
        return 0
    fi
    count=$(wc -l <<< "$packages")
    ok "$count foreign package(s) installed"
    sed 's/^/    /' <<< "$packages" | log_block
    record "foreign" "OK" "$count foreign package(s)"
}

check_bootloader() {
    step "Health — bootloader"
    if [[ ! -d /sys/firmware/efi ]]; then
        skip "system is not booted with UEFI"
        record "bootloader" "SKIP" "non-UEFI"
        return 0
    fi
    local has_sdboot=0 has_grub=0
    local -a bctl=(bootctl)
    sudo -n true 2>/dev/null && bctl=(sudo bootctl)
    if need_cmd bootctl && "${bctl[@]}" is-installed &>/dev/null; then has_sdboot=1; fi
    if [[ -f /boot/grub/grub.cfg ]] || pacman -Q grub &>/dev/null; then has_grub=1; fi
    if (( has_sdboot )); then
        if systemctl is-enabled --quiet systemd-boot-update.service 2>/dev/null; then
            ok "systemd-boot (auto-update service enabled)"
            record "bootloader" "OK" "systemd-boot"
        else
            warn_msg "systemd-boot-update.service is not enabled — run 'sudo bootctl update' after systemd updates"
            record "bootloader" "WARN" "systemd-boot not auto-updated"
        fi
    elif (( has_grub )); then
        ok "GRUB detected"
        record "bootloader" "OK" "GRUB"
    else
        info "UEFI system (bootloader detection inconclusive)"
        record "bootloader" "OK" "UEFI"
    fi
}

check_journal_errors() {
    step "Health — current boot journal errors"
    if ! need_cmd journalctl; then
        skip "journalctl not found"
        record "journal_errors" "SKIP"
        return 0
    fi
    local errors count
    errors=$(journalctl -q -b -p err --no-pager -o short-monotonic 2>/dev/null || true)
    if [[ -z "$errors" ]]; then
        ok "No priority err entries in current boot"
        record "journal_errors" "OK"
        return 0
    fi
    count=$(wc -l <<< "$errors")
    if [[ "$count" -gt 20 ]]; then
        warn_msg "$count error entries in journal (high count; see log)"
        tail -n 5 <<< "$errors" | while IFS= read -r line; do log "    $line"; done
        record "journal_errors" "WARN" "$count errors"
    else
        info "$count error entry/entries in journal"
        tail -n 5 <<< "$errors" | while IFS= read -r line; do log "    $line"; done
        record "journal_errors" "OK" "$count errors logged"
    fi
    sed 's/^/    /' <<< "$errors" | log_block
}

check_reboot_required() {
    step "Health — reboot required check"
    local running_k
    running_k=$(uname -r)
    if [[ ! -d "/usr/lib/modules/$running_k" ]]; then
        warn_msg "Kernel updated ($running_k modules removed) — REBOOT REQUIRED"
        record "reboot" "WARN" "reboot required (running $running_k)"
        return 0
    fi
    ok "Running kernel ($running_k) matches disk modules"
    record "reboot" "OK" "running $running_k"
}

run_postflight() {
    section "POST-FLIGHT HEALTH CHECKS"
    check_failed_services || true
    check_failed_user_services || true
    check_package_integrity || true
    check_pacnew || true
    check_foreign_packages || true
    check_bootloader || true
    check_journal_errors || true
    check_reboot_required || true
}
