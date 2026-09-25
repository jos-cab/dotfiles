#!/usr/bin/env bash
# ─────────────────────────────────────────────
# system-update — Arch + Hyprland modular updater
# ─────────────────────────────────────────────
# Módulos incluidos (selección 3,8,9,10,11,13,14,17,28,34,35,36,38,39,40,41,42,44)
# + paru (sistema) y npm (global) del script original.
#
# Uso:
#   system-update.sh              # menú de tareas seleccionables
#   system-update.sh --all        # corre todo
#   system-update.sh --update     # solo updates
#   system-update.sh --cleanup    # solo limpieza
#   system-update.sh --health     # solo health check
#   system-update.sh --help
#
# Requiere: paru, pacman-contrib (paccache,pacdiff), uv, pipx, npm (opcionales)
# Lanzador recomendado (Hyprland keybind):
#   kitty -e ~/.config/hypr/scripts/system-update/system-update.sh

set -uo pipefail

# ─────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────
JOURNAL_KEEP="${JOURNAL_KEEP:-30d}"      # journalctl --vacuum-time
PACMAN_CACHE_KEEP="${PACMAN_CACHE_KEEP:-2}"  # paccache -rkN (cuántas versiones mantener)
LOCKFILE="/tmp/system-update.lock"
LOGDIR="${XDG_STATE_HOME:-$HOME/.local/state}/system-update"
LOGFILE="$LOGDIR/update-$(date +%Y-%m-%d_%H%M%S).log"
KEEP_LOG=0
cleanup_on_exit() {
    local rc=$?
    if [[ $KEEP_LOG -eq 0 && -f "$LOGFILE" ]]; then
        rm -f "$LOGFILE" 2>/dev/null || true
    fi
    exit $rc
}
trap cleanup_on_exit EXIT INT TERM
DISK_WARN_THRESHOLD=90                   # % uso para warning
DISK_CRIT_THRESHOLD=95                   # % uso para crítico
REBOOT_CHECK_KERNELS=("linux" "linux-zen" "linux-lts" "linux-hardened")

mkdir -p "$LOGDIR" 2>/dev/null || true

# ─────────────────────────────────────────────
# UI / Logging  (36)
# ─────────────────────────────────────────────
if [[ -t 1 ]] && command -v tput &>/dev/null && [[ $(tput colors 2>/dev/null || echo 0) -ge 8 ]]; then
    C_RESET="$(tput sgr0)"
    C_BOLD="$(tput bold)"
    C_RED="$(tput setaf 1)"
    C_GREEN="$(tput setaf 2)"
    C_YELLOW="$(tput setaf 3)"
    C_BLUE="$(tput setaf 4)"
    C_MAGENTA="$(tput setaf 5)"
    C_CYAN="$(tput setaf 6)"
    C_DIM="$(tput dim)"
else
    C_RESET=""; C_BOLD=""; C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_MAGENTA=""; C_CYAN=""; C_DIM=""
fi

ICON_OK="✔"; ICON_FAIL="✘"; ICON_SKIP="○"; ICON_WARN="⚠"; ICON_INFO="ℹ"

# Resultados para summary (38)
declare -A RESULTS=()   # clave -> "OK|FAIL|SKIP|WARN: mensaje"
ORDER=()                # orden de ejecución para el resumen

log()       { echo -e "$*" | tee -a "$LOGFILE"; }
log_plain() { echo -e "$*" >> "$LOGFILE"; }

header() {
    local title="${1:-SYSTEM UPDATE}"
    local width=38
    # truncar si es muy largo
    if (( ${#title} > width )); then
        title="${title:0:$((width-3))}..."
    fi
    local pad=$(( (width - ${#title}) / 2 ))
    local pad2=$(( width - ${#title} - pad ))
    local centered
    centered="$(printf "%*s%s%*s" "$pad" "" "$title" "$pad2" "")"
    echo ""
    log "${C_CYAN}${C_BOLD}╔$(printf '═%.0s' $(seq 1 $((width+4))))╗${C_RESET}"
    log "${C_CYAN}${C_BOLD}║${C_RESET}  ${C_BOLD}${centered}${C_RESET}  ${C_CYAN}${C_BOLD}║${C_RESET}"
    log "${C_CYAN}${C_BOLD}╚$(printf '═%.0s' $(seq 1 $((width+4))))╝${C_RESET}"
    echo ""
}

section() {
    local title="${1:-}"
    echo ""
    # línea tipo: ── TITLE ─────────────────────
    local line="── ${title} "
    local cols=42
    local fill=$(( cols - ${#line} ))
    (( fill < 0 )) && fill=0
    log "${C_CYAN}${C_BOLD}${line}${C_DIM}$(printf '─%.0s' $(seq 1 $fill))${C_RESET}"
    echo ""
}

separator() { log "${C_DIM}────────────────────────────────────────────${C_RESET}"; }

step()     { log "${C_BLUE}${C_BOLD}▶${C_RESET} ${C_BOLD}$*${C_RESET}"; }
ok()       { log "  ${C_GREEN}${ICON_OK} $*${C_RESET}"; }
warn_msg() { log "  ${C_YELLOW}${ICON_WARN} $*${C_RESET}"; }
fail()     { log "  ${C_RED}${ICON_FAIL} $*${C_RESET}"; }
skip()     { log "  ${C_DIM}${ICON_SKIP} $*${C_RESET}"; }
info()     { log "  ${C_DIM}${ICON_INFO} $*${C_RESET}"; }

record() {
    local key="$1" status="$2" msg="${3:-}"
    RESULTS["$key"]="$status${msg:+: $msg}"
    # mantener orden
    [[ " ${ORDER[*]} " == *" $key "* ]] || ORDER+=("$key")
}

need_cmd() {
    command -v "$1" &>/dev/null
}

confirm() {
    local prompt="$1" def="${2:-N}" ans
    [[ "${AUTO_CONFIRM:-0}" -eq 1 ]] && return 0
    if [[ "$def" == "Y" ]]; then
        prompt+=" [Y/n]: "
    else
        prompt+=" [y/N]: "
    fi
    if ! read -r -p "$(echo -e "${C_YELLOW}$prompt${C_RESET} ")" ans; then
        # EOF / Ctrl-D -> tratar como N
        echo ""
        return 1
    fi
    ans="${ans:-$def}"
    # permitir q para salir rápido
    if [[ "$ans" =~ ^[qQ]$ ]]; then
        log "Aborted by user (q)."
        exit 0
    fi
    [[ "$ans" =~ ^[Yy]$ ]]
}

pause_before_close() {
    # solo pausa si estamos en kitty/Hyprland
    if [[ -n "${KITTY_PID:-}" ]] || [[ "${TERM:-}" == "xterm-kitty" ]]; then
        echo ""
        # read con timeout implícito: Ctrl+C sale, q sale
        local ans
        if ! read -r -p "$(echo -e "${C_DIM}Press ENTER to close (q to quit)…${C_RESET} ")" ans; then
            exit 0
        fi
        [[ "${ans,,}" == "q" ]] && exit 0
    fi
}

handle_post_failure() {
    # Llamado tras show_summary en modos no interactivos.
    # Si hubo FAIL, ofrece reintentar / ir al menú / salir en vez de dejar la terminal bloqueada.
    local has_fail=0 orig_args=("$@")
    for k in "${!RESULTS[@]}"; do
        [[ "${RESULTS[$k]:-}" == FAIL* ]] && has_fail=1
    done
    [[ $has_fail -eq 0 ]] && return 0
    echo ""
    warn_msg "Some tasks failed — remaining tasks continued."
    if [[ ! -t 0 ]]; then
        return 0
    fi
    echo ""
    log "  ${C_YELLOW}What would you like to do now?${C_RESET}"
    log "    ${C_BOLD}[r]${C_RESET} Retry  ${C_BOLD}[m]${C_RESET} Menu  ${C_BOLD}[c/Enter]${C_RESET} Close  ${C_BOLD}[q]${C_RESET} Quit"
    local ans
    if ! read -r -p "$(echo -e "${C_CYAN}Choose [r/m/c/q]: ${C_RESET}")" ans; then
        exit 1
    fi
    ans="${ans:-c}"
    case "${ans,,}" in
        r) log "Retrying: $0 ${orig_args[*]}"; exec "$0" "${orig_args[@]}" ;;
        m) log "Opening menu…"; interactive_menu; exit 0 ;;
        c|q|"") log "Exiting."; exit 0 ;;
        *) exit 0 ;;
    esac
}

# ─────────────────────────────────────────────
# Single instance (41)
# ─────────────────────────────────────────────
acquire_lock() {
    exec 200>"$LOCKFILE" || { fail "Could not open lockfile $LOCKFILE"; exit 1; }
    if ! flock -n 200; then
        fail "Another instance of system-update is already running (lock $LOCKFILE)"
        exit 1
    fi
    # el lock se libera automáticamente al cerrar fd 200 / salir
}

# ─────────────────────────────────────────────
# Sudo session (39)
# ─────────────────────────────────────────────
SUDO_PID=""
ensure_sudo() {
    if sudo -n true 2>/dev/null; then
        info "Sudo session already active"
        return 0
    fi
    step "Authenticating sudo"
    if ! sudo -v; then
        fail "Could not authenticate sudo — continuing without sudo where possible (Ctrl+C to abort)"
        return 1
    fi
    # keep-alive en background
    ( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) &
    SUDO_PID=$!
    # preservar trap EXIT previo y añadir SIGINT/SIGTERM para poder salir con Ctrl+C
    local prev_exit
    prev_exit="$(trap -p EXIT | sed -n "s/trap -- '\(.*\)' EXIT/\1/p")"
    # shellcheck disable=SC2064
    trap "kill \"$SUDO_PID\" 2>/dev/null || true; ${prev_exit:-cleanup_on_exit};" EXIT
    trap 'kill "$SUDO_PID" 2>/dev/null || true; echo ""; log "Interrupted (Ctrl+C)."; cleanup_on_exit' INT TERM
    ok "sudo authenticated (keep-alive PID $SUDO_PID)"
}

# ─────────────────────────────────────────────
# Helpers — skip_unnecessary (40)
# ─────────────────────────────────────────────
has_orphans() { pacman -Qtdq &>/dev/null; }
has_pacnew() {
    if need_cmd pacdiff; then
        pacdiff -o 2>/dev/null | grep -q .
    else
        find /etc -name "*.pacnew" -o -name "*.pacsave" 2>/dev/null | grep -q .
    fi
}

# ─────────────────────────────────────────────
# Update modules
# ─────────────────────────────────────────────

update_reflector() {
    step "Mirrors — reflector"
    if ! need_cmd reflector; then
        skip "reflector not installed"
        record "reflector" "SKIP" "not installed"
        return 0
    fi
    if sudo_run reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist; then
        ok "Mirrorlist updated"
        record "reflector" "OK"
    else
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
        skip "paru not installed — skipped"
        record "paru" "SKIP" "not installed"
        return 0
    fi
    # (40) skip_unnecessary: si no hay nada para actualizar, avisar pero igual correr?
    # paru no tiene dry-run barato sin sync; lo ejecutamos directo.
    if paru -Syu --noconfirm 2>&1 | tee -a "$LOGFILE"; then
        ok "paru -Syu completed"
        record "paru" "OK"
    else
        fail "paru -Syu failed (see log $LOGFILE)"
        record "paru" "FAIL"
        return 1
    fi
}

# helper: ejecuta con sudo sin bloquear si no hay credenciales
# devuelve 0 si ok, 1 si no se pudo (sin colgar pidiendo password sin TTY)
sudo_run() {
    # si ya tenemos sudo activo, usar sudo normal (puede pedir password con TTY)
    if sudo -n true 2>/dev/null; then
        sudo "$@" 2>&1 | tee -a "$LOGFILE"
        return "${PIPESTATUS[0]}"
    fi
    # sin credenciales: intentar sudo -n (no pedir password) — si falla, omitir
    if [[ ! -t 0 ]]; then
        # sin TTY no podemos pedir password — saltar
        return 1
    fi
    # con TTY, intentar sudo -v de nuevo (pedirá password)
    if sudo -v 2>&1 | tee -a "$LOGFILE"; then
        sudo "$@" 2>&1 | tee -a "$LOGFILE"
        return "${PIPESTATUS[0]}"
    fi
    return 1
}

update_npm() {
    step "npm — global packages"
    if ! need_cmd npm; then
        skip "npm not installed — skipped"
        record "npm" "SKIP" "not installed"
        return 0
    fi
    if ! sudo_run npm -g update; then
        fail "npm update failed or was cancelled"
        record "npm" "FAIL"
        return 1
    fi
    ok "npm global update OK"
    record "npm" "OK"
}

update_uv_tools() {  # (3)
    step "uv — tool upgrade --all"
    if ! need_cmd uv; then
        skip "uv not installed — skipped"
        record "uv" "SKIP" "not installed"
        return 0
    fi
    # (40) si no hay tools, skip
    if ! uv tool list 2>/dev/null | grep -q "installed"; then
        # uv tool list puede variar; si falla, igual intentamos
        local count
        count=$(uv tool list 2>/dev/null | wc -l)
        if [[ "$count" -le 1 ]]; then
            skip "no uv tools installed"
            record "uv" "SKIP" "no tools"
            return 0
        fi
    fi
    if uv tool upgrade --all 2>&1 | tee -a "$LOGFILE"; then
        ok "uv tools updated"
        record "uv" "OK"
    else
        fail "uv tool upgrade failed"
        record "uv" "FAIL"
        return 1
    fi
}

update_pipx() {  # (28)
    step "pipx — upgrade-all"
    if ! need_cmd pipx; then
        skip "pipx not installed — skipped"
        record "pipx" "SKIP" "not installed"
        return 0
    fi
    local list
    list=$(pipx list 2>/dev/null || true)
    if ! echo "$list" | grep -q "package"; then
        skip "no pipx packages"
        record "pipx" "SKIP" "no packages"
        return 0
    fi
    if pipx upgrade-all 2>&1 | tee -a "$LOGFILE"; then
        ok "pipx upgrade-all OK"
        record "pipx" "OK"
    else
        fail "pipx upgrade-all failed"
        record "pipx" "FAIL"
        return 1
    fi
}

# ─────────────────────────────────────────────
# System checks (13,14,11,17)
# ─────────────────────────────────────────────

check_disk_space() {  # (13)
    step "Check — disk space (/, /home, /boot)"
    local failed=0
    for mnt in "/" "/home" "/boot" "/efi"; do
        [[ -d "$mnt" ]] || continue
        # df -hP para parsear
        local line use_perc avail
        line=$(df -hP "$mnt" 2>/dev/null | tail -1 || true)
        [[ -z "$line" ]] && continue
        use_perc=$(echo "$line" | awk '{print $5}' | tr -d '%')
        avail=$(echo "$line" | awk '{print $4}')
        if [[ "$use_perc" -ge "$DISK_CRIT_THRESHOLD" ]]; then
            fail "$mnt at ${use_perc}% (avail: $avail) — CRITICAL"
            failed=1
        elif [[ "$use_perc" -ge "$DISK_WARN_THRESHOLD" ]]; then
            warn_msg "$mnt at ${use_perc}% (avail: $avail) — low space"
        else
            ok "$mnt ${use_perc}% used (avail: $avail)"
        fi
        log_plain "    $line"
    done
    if [[ $failed -eq 1 ]]; then
        record "disk" "WARN" "critical space on one or more partitions"
    else
        record "disk" "OK"
    fi
}

check_package_integrity() {  # (14)
    step "Check — package integrity (pacman -Qk)"
    if ! need_cmd pacman; then
        skip "pacman not found"
        record "integrity" "SKIP"
        return 0
    fi
    local out
    if sudo -n true 2>/dev/null; then
        out=$(sudo pacman -Qk 2>&1 | tee -a "$LOGFILE" || true)
    else
        out=$(pacman -Qk 2>&1 | tee -a "$LOGFILE" || true)
    fi
    if echo "$out" | grep -qiE "missing files"; then
        warn_msg "Missing files detected (see log)"
        echo "$out" | grep -iE "missing files" | grep -v "0 missing files" | head -n 20 | while read -r l; do log "    $l"; done
        record "integrity" "WARN" "missing files"
    else
        ok "Integrity OK"
        record "integrity" "OK"
    fi
}

check_pacnew() {  # (11)
    step "Check — .pacnew / .pacsave"
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
    if [[ "${AUTO_CONFIRM:-0}" -eq 1 ]]; then
        info "Skipped — review manually with: pacdiff -o && sudo pacdiff"
    elif confirm "Open pacdiff to merge?" "N"; then
        if ! need_cmd pacdiff; then
            warn_msg "pacdiff not installed (pacman-contrib). Files listed above."
        elif ! sudo -n true 2>/dev/null; then
            warn_msg "sudo not available — review manually with: pacdiff -o && sudo pacdiff"
        else
            # pacdiff es interactivo; no redirigir a log
            sudo pacdiff || true
        fi
    else
        info "Skipped — review manually with: pacdiff -o && sudo pacdiff"
    fi
}

check_reboot_required() {  # (17)
    step "Check — reboot required?"
    local need_reboot=0 reason=""

    # 1) kernel en ejecución vs módulos en disco
    local running
    running=$(uname -r)
    if [[ ! -d "/usr/lib/modules/$running" ]]; then
        need_reboot=1
        reason+="running kernel $running modules replaced on disk; "
    fi

    # 2) librerías borradas en uso (lsof +D o checkservices)
    if need_cmd lsof; then
        local deleted
        deleted=$(lsof +c 0 2>/dev/null | grep -c "(deleted)" || true)
        if [[ "$deleted" -gt 0 ]]; then
            need_reboot=1
            reason+="$deleted processes using deleted libraries; "
        fi
    elif need_cmd needrestart 2>/dev/null; then
        : # alternativa no implementada
    fi

    # 3) flag explícito de algunas distros
    if [[ -f /run/reboot-required ]]; then
        need_reboot=1
        reason+="/run/reboot-required present; "
    fi

    if [[ $need_reboot -eq 1 ]]; then
        warn_msg "REBOOT RECOMMENDED — $reason"
        log "    ${C_YELLOW}Hint: reboot when convenient (sudo reboot)${C_RESET}"
        record "reboot" "WARN" "reboot recommended"
    else
        ok "No reboot required"
        record "reboot" "OK"
    fi
}

# ─────────────────────────────────────────────
# Maintenance modules (8,10,9,34,35)
# ─────────────────────────────────────────────

show_cache_usage() {  # (34)
    step "Caches — disk usage"
    local total_line=""
    # pacman cache
    if [[ -d /var/cache/pacman/pkg ]]; then
        local sz
        sz=$(du -sh /var/cache/pacman/pkg 2>/dev/null | awk '{print $1}')
        log "    pacman cache: ${C_BOLD}${sz:-?}${C_RESET}  (/var/cache/pacman/pkg)"
    else
        log "    pacman cache: not found"
    fi
    # paru cache: build + pkg cache
    local paru_cache="$HOME/.cache/paru"
    if [[ -d "$paru_cache" ]]; then
        local sz2
        sz2=$(du -sh "$paru_cache" 2>/dev/null | awk '{print $1}')
        log "    paru cache:   ${C_BOLD}${sz2:-?}${C_RESET}  ($paru_cache)"
        # detalle clone
        if [[ -d "$paru_cache/clone" ]]; then
            local szc
            szc=$(du -sh "$paru_cache/clone" 2>/dev/null | awk '{print $1}')
            log "      └─ clone: ${szc:-?}"
        fi
    else
        log "    paru cache:   not found"
    fi
    # journal
    if need_cmd journalctl; then
        local jsz
        jsz=$(journalctl --disk-usage 2>/dev/null | grep -oE "[0-9.]+[a-zA-Z]+" | head -1 || echo "?")
        log "    journal:      ${C_BOLD}${jsz:-?}${C_RESET}"
    fi
    # pipx/uv caches opcionales
    if [[ -d "$HOME/.cache/pip" ]]; then
        local spip
        spip=$(du -sh "$HOME/.cache/pip" 2>/dev/null | awk '{print $1}')
        log "    pip cache:    ${spip:-?}"
    fi
    record "cache_usage" "OK"
}

cleanup_pacman_cache() {  # (8)
    step "Cleanup — pacman cache (paccache -rk$PACMAN_CACHE_KEEP)"
    if ! need_cmd paccache; then
        skip "paccache not installed (pacman-contrib) — skipped"
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
    if sudo paccache -rk"$PACMAN_CACHE_KEEP" 2>&1 | tee -a "$LOGFILE"; then
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

cleanup_paru_cache() {  # (10) conservadora
    step "Cleanup — paru cache (conservative)"
    local cache_dir="$HOME/.cache/paru"
    if [[ ! -d "$cache_dir" ]] && ! need_cmd paru; then
        skip "paru not installed / no cache"
        record "paru_cache" "SKIP" "no cache"
        return 0
    fi
    # clones viejos: informativo
    if [[ -d "$cache_dir/clone" ]]; then
        local count size
        count=$(find "$cache_dir/clone" -maxdepth 1 -type d 2>/dev/null | wc -l)
        size=$(du -sh "$cache_dir/clone" 2>/dev/null | awk '{print $1}')
        info "AUR clones: $((count-1)) directories, $size"
        if confirm "Clean clones unused for >30 days? (find -mtime +30)" "N"; then
            find "$cache_dir/clone" -mindepth 1 -maxdepth 1 -type d -mtime +30 -print 2>/dev/null | while read -r d; do log "    removing $d"; done
            find "$cache_dir/clone" -mindepth 1 -maxdepth 1 -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
            ok "Old clones removed"
        else
            info "Clones preserved"
        fi
    fi
    record "paru_cache" "OK"
}

check_orphans() {  # (9)
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
    echo "$orphans" | while read -r p; do log "    $p"; done
    # mostrar detalle
    pacman -Qtd 2>/dev/null | head -n 20 | while read -r l; do log "    $l"; done
    log "    ${C_DIM}(Review: pacman -Qtd — Arch recommends not removing blindly)${C_RESET}"
    record "orphans" "WARN" "$count orphan(s)"
    if confirm "Remove orphans now? (pacman -Rns)" "N"; then
        if ! sudo -n true 2>/dev/null; then
            fail "Could not remove orphans — sudo not available"
            record "orphans" "FAIL" "no sudo"
            return 1
        fi
        # shellcheck disable=SC2046
        if sudo pacman -Rns $(pacman -Qtdq) 2>&1 | tee -a "$LOGFILE"; then
            ok "Orphans removed"
            record "orphans" "OK" "removed"
        else
            fail "Could not remove orphans"
            record "orphans" "FAIL"
            return 1
        fi
    else
        info "Orphans preserved"
    fi
}

vacuum_journal() {  # (35)
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
    if sudo journalctl --vacuum-time="$JOURNAL_KEEP" 2>&1 | tee -a "$LOGFILE"; then
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

# ─────────────────────────────────────────────
# Summary (38)
# ─────────────────────────────────────────────
show_summary() {
    separator
    section "SUMMARY"
    local has_fail=0 has_warn=0
    for key in "${ORDER[@]}"; do
        local val="${RESULTS[$key]}"
        local status="${val%%:*}"
        local msg="${val#*:}"
        [[ "$msg" == "$status" ]] && msg=""
        case "$status" in
            OK)   log "  ${C_GREEN}${ICON_OK}  ${C_BOLD}$(printf "%-16s" "$key")${C_RESET} ${C_GREEN}OK${C_RESET}${msg:+ ${C_DIM}$msg${C_RESET}}";;
            SKIP) log "  ${C_DIM}${ICON_SKIP}  $(printf "%-16s" "$key") SKIP${msg:+ $msg}${C_RESET}";;
            WARN) log "  ${C_YELLOW}${ICON_WARN}  $(printf "%-16s" "$key") ${C_YELLOW}WARN${C_RESET}${msg:+ ${C_DIM}$msg${C_RESET}}"; has_warn=1;;
            FAIL) log "  ${C_RED}${ICON_FAIL}  $(printf "%-16s" "$key") ${C_RED}FAIL${C_RESET}${msg:+ $msg}"; has_fail=1;;
            *)    log "  $key: $val";;
        esac
    done
    echo ""
    if [[ $has_fail -eq 1 ]]; then
        log "  ${C_RED}${C_BOLD}Some tasks failed — check log: $LOGFILE${C_RESET}"
    elif [[ $has_warn -eq 1 ]]; then
        log "  ${C_YELLOW}Completed with warnings — see above.${C_RESET}"
    else
        log "  ${C_GREEN}${C_BOLD}All OK${C_RESET}"
    fi
    log "  ${C_DIM}Log: $LOGFILE${C_RESET}"
    echo ""
}

# ─────────────────────────────────────────────
# Notify (44)
# ─────────────────────────────────────────────
send_notify() {
    local title="$1" body="$2" urgency="${3:-normal}"
    if need_cmd notify-send; then
        notify-send -u "$urgency" -a "system-update" "$title" "$body" 2>/dev/null || true
    fi
    # también log
    log_plain "[notify] $title — $body"
}

# ─────────────────────────────────────────────
# Grupos de tareas (para menú)
# ─────────────────────────────────────────────

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

run_cleanup() {
    section "CLEANUP"
    show_cache_usage || true
    # cada limpieza pregunta; no es destructiva sin confirmar (salvo paccache/paru -Sc)
    if confirm "Clean pacman cache (paccache -rk$PACMAN_CACHE_KEEP)?" "N"; then
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

run_health() {
    section "HEALTH CHECK"
    check_package_integrity || true
    check_pacnew || true
    show_cache_usage || true
}

run_full_maintenance() {
    run_updates
    run_cleanup
    run_health
}

run_everything() {
    run_full_maintenance
}

save_log_prompt() {
    if confirm "Save log to $LOGFILE?" "N"; then
        KEEP_LOG=1
        log "Log saved: $LOGFILE"
    else
        KEEP_LOG=0
        rm -f "$LOGFILE" 2>/dev/null || true
    fi
}

run_selected() {
    ensure_sudo || true
    AUTO_CONFIRM=1
    [[ ${SELECT_PREFLIGHT:-0} -eq 1 ]] && check_disk_space || true
    [[ ${SELECT_REFLECTOR:-0} -eq 1 ]] && update_reflector || true
    [[ ${SELECT_KEYS:-0} -eq 1 ]] && repair_pacman_keys || true
    [[ ${SELECT_UPDATE:-0} -eq 1 ]] && update_system || true
    [[ ${SELECT_NPM:-0} -eq 1 ]] && update_npm || true
    [[ ${SELECT_UV:-0} -eq 1 ]] && update_uv_tools || true
    [[ ${SELECT_PIPX:-0} -eq 1 ]] && update_pipx || true
    [[ ${SELECT_HEALTH:-0} -eq 1 ]] && run_health || true
    [[ ${SELECT_ORPHANS:-0} -eq 1 ]] && check_orphans || true
    [[ ${SELECT_CACHE:-0} -eq 1 ]] && cleanup_pacman_cache || true
    [[ ${SELECT_CACHE:-0} -eq 1 ]] && cleanup_paru_cache || true
    [[ ${SELECT_JOURNAL:-0} -eq 1 ]] && vacuum_journal || true
    check_reboot_required || true
    show_summary
    AUTO_CONFIRM=0
    send_notify "System Update" "Selected tasks completed"
    save_log_prompt
}

interactive_menu() {
    local -a items=(
        "Disk space"
        "Update mirrors"
        "Repair pacman keys"
        "Update system (paru)"
        "Update npm packages"
        "Update uv tools"
        "Update pipx tools"
        "System health check"
        "Remove orphan packages"
        "Clean caches"
        "Clean journal"
    )
    local -a sel=(0 0 0 1 0 0 0 0 0 0 0)
    local cur=3 total=${#items[@]} key c esc

    local icon_checked="󰄲"
    local icon_unchecked="󰄱"

    tput civis 2>/dev/null || true
    trap 'tput cnorm 2>/dev/null || true' EXIT INT TERM

    while true; do
        printf '\033[H'
        echo -e "${C_BOLD}Select tasks to execute:${C_RESET}"
        echo ""
        for ((i=0; i<total; i++)); do
            if [[ ${sel[$i]} -eq 1 ]]; then
                c="${C_GREEN}${icon_checked}${C_RESET}"
            else
                c="${C_DIM}${icon_unchecked}${C_RESET}"
            fi
            if [[ $i -eq $cur ]]; then
                echo -e "  ${C_CYAN}${C_BOLD}❯ ${c}  ${items[$i]}${C_RESET}"
            else
                echo -e "    ${c}  ${items[$i]}"
            fi
        done
        echo ""
        if [[ $cur -eq $total ]]; then
            echo -e "  ${C_CYAN}${C_BOLD}╭───────────────╮${C_RESET}"
            echo -e "  ${C_CYAN}${C_BOLD}│   ✔ Apply     │${C_RESET}"
            echo -e "  ${C_CYAN}${C_BOLD}╰───────────────╯${C_RESET}"
        else
            echo -e "  ${C_DIM}╭───────────────╮${C_RESET}"
            echo -e "  ${C_DIM}│     Apply     │${C_RESET}"
            echo -e "  ${C_DIM}╰───────────────╯${C_RESET}"
        fi
        echo ""
        echo -e "${C_DIM}↑/↓ move   Space/Enter toggle or apply   q quit${C_RESET}"
        printf '\033[J'

        IFS= read -rsn1 key || break
        case "$key" in
            q|Q)
                tput cnorm 2>/dev/null || true
                exit 0
                ;;
            " ")
                if [[ $cur -lt $total ]]; then
                    sel[$cur]=$(( 1 - sel[$cur] ))
                else
                    break
                fi
                ;;
            "")
                if [[ $cur -eq $total ]]; then
                    break
                fi
                sel[$cur]=$(( 1 - sel[$cur] ))
                ;;
            $'\x1b')
                read -rsn2 -t 0.05 esc || esc=""
                case "$esc" in
                    '[A') ((cur > 0)) && ((cur--)) ;;
                    '[B') ((cur < total)) && ((cur++)) ;;
                esac
                ;;
        esac
    done

    tput cnorm 2>/dev/null || true
    printf '\033[2J\033[H'

    SELECT_PREFLIGHT=${sel[0]}
    SELECT_REFLECTOR=${sel[1]}
    SELECT_KEYS=${sel[2]}
    SELECT_UPDATE=${sel[3]}
    SELECT_NPM=${sel[4]}
    SELECT_UV=${sel[5]}
    SELECT_PIPX=${sel[6]}
    SELECT_HEALTH=${sel[7]}
    SELECT_ORPHANS=${sel[8]}
    SELECT_CACHE=${sel[9]}
    SELECT_JOURNAL=${sel[10]}

    run_selected
    pause_before_close
}

print_help() {
    cat <<EOF
system-update — modular updater for Arch + Hyprland

Usage: $(basename "$0") [option]

Options:
  (no args)    selectable task menu
  --all, -a    run everything (update + cleanup + health) without menu
  --update     full update only (paru, npm, uv, pipx)
  --dev        dev tools only (uv, pipx)
  --cleanup    cleanup only
  --health     health check only
  --help, -h   show this help

Environment variables:
  JOURNAL_KEEP=30d        days to keep in journal vacuum
  PACMAN_CACHE_KEEP=2     versions to keep in paccache

Log: \$LOGDIR/update-*.log  (current: $LOGFILE)
Lock: $LOCKFILE
EOF
}

# ─────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────
main() {
    acquire_lock
    # log header
    {
        echo "=== system-update $(date -Is) ==="
        echo "host: $(cat /etc/hostname 2>/dev/null || echo unknown)  user: $(whoami)  kernel: $(uname -r)"
        echo "args: $*"
        echo ""
    } >> "$LOGFILE"

    # Si se ejecuta desde un lanzador gráfico, abrir una terminal solo cuando sea posible.
    if [[ ! -t 0 ]] && [[ ! -t 1 ]] && [[ "${1:-}" != "--help" ]] && [[ "${1:-}" != "-h" ]]; then
        if need_cmd kitty && [[ -z "${SYSTEM_UPDATE_RELAUNCHED:-}" ]]; then
            export SYSTEM_UPDATE_RELAUNCHED=1
            exec kitty -e "$0" "$@"
        fi
    fi

    case "${1:-}" in
        --help|-h) print_help; exit 0 ;;
        --all|-a)
            ensure_sudo || true
            header "RUN EVERYTHING"
            run_everything
            show_summary
            # determinar urgencia para notify
            local has_fail=0
            for k in "${!RESULTS[@]}"; do [[ "${RESULTS[$k]:-}" == FAIL* ]] && has_fail=1; done
            if [[ $has_fail -eq 1 ]]; then
                send_notify "System Update — FAIL" "Some tasks failed. Log: $LOGFILE" critical
            else
                send_notify "System Update — OK" "Run everything completed"
            fi
            handle_post_failure --all
            pause_before_close
            ;;
        --update)
            ensure_sudo || true
            header "FULL UPDATE"
            run_updates; show_summary
            send_notify "System Update" "Full update completed"
            handle_post_failure --update
            pause_before_close
            ;;
        --dev)
            header "DEV TOOLS"
            run_devtools; show_summary
            pause_before_close
            ;;
        --cleanup)
            ensure_sudo || true
            header "CLEANUP"
            run_cleanup; show_summary
            handle_post_failure --cleanup
            pause_before_close
            ;;
        --health)
            header "HEALTH CHECK"
            run_health; show_summary
            pause_before_close
            ;;
        "")
            interactive_menu
            ;;
        *)
            echo "Unknown option: $1" >&2
            print_help
            exit 1
            ;;
    esac
}

main "$@"
