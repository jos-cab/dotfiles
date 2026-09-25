#!/usr/bin/env bash
# ─────────────────────────────────────────────
# system-update — Arch + Hyprland modular updater
# ─────────────────────────────────────────────
# Módulos incluidos (selección 3,8,9,10,11,13,14,17,28,34,35,36,38,39,40,41,42,44)
# + paru (sistema) y npm (global) del script original.
#
# Uso:
#   system-update.sh              # menú interactivo (default)
#   system-update.sh --all        # corre todo (opción 6)
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
        log "Abortado por el usuario (q)."
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
        if ! read -r -p "$(echo -e "${C_DIM}Press ENTER para cerrar (q para salir)…${C_RESET} ")" ans; then
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
    warn_msg "Algunas tareas fallaron — el resto continuó para no bloquearte."
    if [[ ! -t 0 ]]; then
        return 0
    fi
    echo ""
    log "  ${C_YELLOW}¿Qué quieres hacer ahora?${C_RESET}"
    log "    ${C_BOLD}[r]${C_RESET} Reintentar  ${C_BOLD}[m]${C_RESET} Menú interactivo  ${C_BOLD}[c/Enter]${C_RESET} Cerrar  ${C_BOLD}[q]${C_RESET} Salir"
    local ans
    if ! read -r -p "$(echo -e "${C_CYAN}Elige [r/m/c/q]: ${C_RESET}")" ans; then
        exit 1
    fi
    ans="${ans:-c}"
    case "${ans,,}" in
        r) log "Reintentando: $0 ${orig_args[*]}"; exec "$0" "${orig_args[@]}" ;;
        m) log "Abriendo menú interactivo…"; interactive_menu; exit 0 ;;
        c|q|"") log "Saliendo."; exit 0 ;;
        *) exit 0 ;;
    esac
}

# ─────────────────────────────────────────────
# Single instance (41)
# ─────────────────────────────────────────────
acquire_lock() {
    exec 200>"$LOCKFILE" || { fail "No se pudo abrir lockfile $LOCKFILE"; exit 1; }
    if ! flock -n 200; then
        fail "Otra instancia de system-update ya está en ejecución (lock $LOCKFILE)"
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
        info "Sesión sudo ya activa"
        return 0
    fi
    step "Autenticando sudo (se pedirá contraseña una sola vez)"
    if ! sudo -v; then
        fail "No se pudo autenticar sudo — se continuará sin sudo donde sea posible (Ctrl+C para abortar)"
        return 1
    fi
    # keep-alive en background
    ( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) &
    SUDO_PID=$!
    # preservar trap EXIT previo y añadir SIGINT/SIGTERM para poder salir con Ctrl+C
    local prev_exit
    prev_exit="$(trap -p EXIT | sed -n "s/trap -- '\(.*\)' EXIT/\1/p")"
    # shellcheck disable=SC2064
    trap "kill \"$SUDO_PID\" 2>/dev/null || true; ${prev_exit:-};" EXIT
    trap 'kill "$SUDO_PID" 2>/dev/null || true; echo ""; log "Interrumpido (Ctrl+C)."; exit 130' INT TERM
    ok "sudo autenticado (keep-alive PID $SUDO_PID)"
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

update_system() {
    step "Sistema — paru -Syu"
    if ! need_cmd paru; then
        skip "paru no instalado — omitido"
        record "paru" "SKIP" "no instalado"
        return 0
    fi
    # (40) skip_unnecessary: si no hay nada para actualizar, avisar pero igual correr?
    # paru no tiene dry-run barato sin sync; lo ejecutamos directo.
    if paru -Syu --noconfirm 2>&1 | tee -a "$LOGFILE"; then
        ok "paru -Syu completado"
        record "paru" "OK"
    else
        fail "paru -Syu falló (ver log $LOGFILE)"
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
    step "npm — paquetes globales"
    if ! need_cmd npm; then
        skip "npm no instalado — omitido"
        record "npm" "SKIP" "no instalado"
        return 0
    fi
    info "Actualizando paquetes globales; puede pedir contraseña sudo"
    if ! sudo_run npm -g update; then
        fail "npm update falló o fue cancelado"
        record "npm" "FAIL"
        return 1
    fi
    ok "npm global update OK"
    record "npm" "OK"
}

update_uv_tools() {  # (3)
    step "uv — tool upgrade --all"
    if ! need_cmd uv; then
        skip "uv no instalado — omitido"
        record "uv" "SKIP" "no instalado"
        return 0
    fi
    # (40) si no hay tools, skip
    if ! uv tool list 2>/dev/null | grep -q "installed"; then
        # uv tool list puede variar; si falla, igual intentamos
        local count
        count=$(uv tool list 2>/dev/null | wc -l)
        if [[ "$count" -le 1 ]]; then
            skip "sin uv tools instaladas"
            record "uv" "SKIP" "sin tools"
            return 0
        fi
    fi
    if uv tool upgrade --all 2>&1 | tee -a "$LOGFILE"; then
        ok "uv tools actualizadas"
        record "uv" "OK"
    else
        fail "uv tool upgrade falló"
        record "uv" "FAIL"
        return 1
    fi
}

update_pipx() {  # (28)
    step "pipx — upgrade-all"
    if ! need_cmd pipx; then
        skip "pipx no instalado — omitido"
        record "pipx" "SKIP" "no instalado"
        return 0
    fi
    local list
    list=$(pipx list 2>/dev/null || true)
    if ! echo "$list" | grep -q "package"; then
        skip "sin paquetes pipx"
        record "pipx" "SKIP" "sin paquetes"
        return 0
    fi
    if pipx upgrade-all 2>&1 | tee -a "$LOGFILE"; then
        ok "pipx upgrade-all OK"
        record "pipx" "OK"
    else
        fail "pipx upgrade-all falló"
        record "pipx" "FAIL"
        return 1
    fi
}

# ─────────────────────────────────────────────
# System checks (13,14,11,17)
# ─────────────────────────────────────────────

check_disk_space() {  # (13)
    step "Chequeo — espacio en disco (/, /home, /boot)"
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
            fail "$mnt al ${use_perc}% (disp. $avail) — CRÍTICO"
            failed=1
        elif [[ "$use_perc" -ge "$DISK_WARN_THRESHOLD" ]]; then
            warn_msg "$mnt al ${use_perc}% (disp. $avail) — bajo espacio"
        else
            ok "$mnt ${use_perc}% usado (disp. $avail)"
        fi
        log_plain "    $line"
    done
    if [[ $failed -eq 1 ]]; then
        record "disk" "WARN" "espacio crítico en alguna partición"
    else
        record "disk" "OK"
    fi
}

check_package_integrity() {  # (14)
    step "Chequeo — integridad de paquetes (pacman -Qk)"
    if ! need_cmd pacman; then
        skip "pacman no encontrado"
        record "integrity" "SKIP"
        return 0
    fi
    local out rc
    out=$(pacman -Qk 2>&1 | tee -a "$LOGFILE" || true)
    # pacman -Qk devuelve 0 aunque haya warnings; detectamos líneas con "missing" o "altered"
    if echo "$out" | grep -qiE "missing|warning|error"; then
        warn_msg "Se detectaron archivos faltantes/modificados (ver log)"
        echo "$out" | grep -iE "missing|warning" | head -n 20 | while read -r l; do log "    $l"; done
        record "integrity" "WARN" "archivos faltantes/modificados"
    else
        ok "Integridad OK"
        record "integrity" "OK"
    fi
}

check_pacnew() {  # (11)
    step "Chequeo — .pacnew / .pacsave"
    local files=""
    if need_cmd pacdiff; then
        files=$(pacdiff -o 2>/dev/null || true)
    else
        files=$(find /etc -name "*.pacnew" -o -name "*.pacsave" 2>/dev/null || true)
    fi
    if [[ -z "$files" ]]; then
        ok "Sin .pacnew/.pacsave pendientes"
        record "pacnew" "OK"
        return 0
    fi
    local count
    count=$(echo "$files" | wc -l)
    warn_msg "$count archivo(s) requieren atención:"
    echo "$files" | while read -r f; do log "    ${C_YELLOW}[pacnew]${C_RESET} $f"; done
    record "pacnew" "WARN" "$count archivo(s)"
    if confirm "¿Abrir pacdiff para fusionar?" "N"; then
        if ! need_cmd pacdiff; then
            warn_msg "pacdiff no instalado (pacman-contrib). Archivos listados arriba."
        elif ! sudo -n true 2>/dev/null; then
            warn_msg "sudo no disponible — revisa manualmente con: pacdiff -o && sudo pacdiff"
        else
            # pacdiff es interactivo; no redirigir a log
            sudo pacdiff || true
        fi
    else
        info "Omitido — revisa manualmente con: pacdiff -o && sudo pacdiff"
    fi
}

check_reboot_required() {  # (17)
    step "Chequeo — ¿reinicio requerido?"
    local need_reboot=0 reason=""

    # 1) kernel en ejecución vs. instalado
    local running installed
    running=$(uname -r)
    for pkg in "${REBOOT_CHECK_KERNELS[@]}"; do
        if pacman -Q "$pkg" &>/dev/null; then
            installed=$(pacman -Q "$pkg" 2>/dev/null | awk '{print $2}' | cut -d- -f1)
            # comparación simple: si running no contiene installed, probablemente hay desfasaje
            if [[ "$running" != *"$installed"* ]]; then
                need_reboot=1
                reason+="kernel $pkg actualizado ($installed) vs running $running; "
            fi
            break
        fi
    done

    # 2) librerías borradas en uso (lsof +D o checkservices)
    if need_cmd lsof; then
        local deleted
        deleted=$(lsof +c 0 2>/dev/null | grep -c "(deleted)" || true)
        if [[ "$deleted" -gt 0 ]]; then
            need_reboot=1
            reason+="$deleted procesos con librerías borradas; "
        fi
    elif need_cmd needrestart 2>/dev/null; then
        : # alternativa no implementada
    fi

    # 3) flag explícito de algunas distros
    if [[ -f /run/reboot-required ]]; then
        need_reboot=1
        reason+="/run/reboot-required presente; "
    fi

    if [[ $need_reboot -eq 1 ]]; then
        warn_msg "REINICIO RECOMENDADO — $reason"
        log "    ${C_YELLOW}Sugerencia: reinicia cuando te sea conveniente (sudo reboot)${C_RESET}"
        record "reboot" "WARN" "reinicio recomendado"
    else
        ok "No se requiere reinicio"
        record "reboot" "OK"
    fi
}

# ─────────────────────────────────────────────
# Maintenance modules (8,10,9,34,35)
# ─────────────────────────────────────────────

show_cache_usage() {  # (34)
    step "Cachés — uso de disco"
    local total_line=""
    # pacman cache
    if [[ -d /var/cache/pacman/pkg ]]; then
        local sz
        sz=$(du -sh /var/cache/pacman/pkg 2>/dev/null | cut -f1)
        log "    pacman cache: ${C_BOLD}$sz${C_RESET}  (/var/cache/pacman/pkg)"
    else
        log "    pacman cache: no encontrado"
    fi
    # paru cache: build + pkg cache
    local paru_cache="$HOME/.cache/paru"
    if [[ -d "$paru_cache" ]]; then
        local sz2
        sz2=$(du -sh "$paru_cache" 2>/dev/null | cut -f1)
        log "    paru cache:   ${C_BOLD}$sz2${C_RESET}  ($paru_cache)"
        # detalle clone
        if [[ -d "$paru_cache/clone" ]]; then
            local szc
            szc=$(du -sh "$paru_cache/clone" 2>/dev/null | cut -f1)
            log "      └─ clone: $szc"
        fi
    else
        log "    paru cache:   no encontrado"
    fi
    # journal
    if need_cmd journalctl; then
        local jsz
        jsz=$(journalctl --disk-usage 2>/dev/null | grep -oE "[0-9.]+[KMGT]B" | head -1 || echo "?")
        log "    journal:      ${C_BOLD}$jsz${C_RESET}"
    fi
    # pipx/uv caches opcionales
    if [[ -d "$HOME/.cache/pip" ]]; then
        log "    pip cache:    $(du -sh "$HOME/.cache/pip" 2>/dev/null | cut -f1)"
    fi
    record "cache_usage" "OK"
}

cleanup_pacman_cache() {  # (8)
    step "Limpieza — caché pacman (paccache -rk$PACMAN_CACHE_KEEP)"
    if ! need_cmd paccache; then
        skip "paccache no instalado (pacman-contrib) — omitido"
        record "pacman_cache" "SKIP" "paccache no instalado"
        return 0
    fi
    if ! sudo -n true 2>/dev/null; then
        skip "paccache omitido — sudo no disponible"
        record "pacman_cache" "SKIP" "sin sudo"
        return 0
    fi
    local before after
    before=$(du -sh /var/cache/pacman/pkg 2>/dev/null | cut -f1 || echo "?")
    info "Tamaño antes: $before"
    if sudo paccache -rk"$PACMAN_CACHE_KEEP" 2>&1 | tee -a "$LOGFILE"; then
        after=$(du -sh /var/cache/pacman/pkg 2>/dev/null | cut -f1 || echo "?")
        ok "Caché limpiada (antes $before → ahora $after)"
        record "pacman_cache" "OK" "$before → $after"
    else
        fail "paccache falló"
        record "pacman_cache" "FAIL"
        return 1
    fi
}

cleanup_paru_cache() {  # (10) conservadora
    step "Limpieza — caché paru (conservadora)"
    local cache_dir="$HOME/.cache/paru"
    if [[ ! -d "$cache_dir" ]] && ! need_cmd paru; then
        skip "paru no instalado / sin caché"
        record "paru_cache" "SKIP" "sin caché"
        return 0
    fi
    # paru -Sc elimina solo paquetes no instalados (conservador)
    # NO usamos -Scc que vacía todo
    if need_cmd paru; then
        info "Ejecutando: paru -Sc --noconfirm (solo no instalados)"
        if paru -Sc --noconfirm 2>&1 | tee -a "$LOGFILE"; then
            ok "paru -Sc OK"
        else
            warn_msg "paru -Sc devolvió error (puede ser normal si no había nada)"
        fi
    fi
    # clones viejos: informativo
    if [[ -d "$cache_dir/clone" ]]; then
        local count size
        count=$(find "$cache_dir/clone" -maxdepth 1 -type d 2>/dev/null | wc -l)
        size=$(du -sh "$cache_dir/clone" 2>/dev/null | cut -f1)
        info "clones AUR: $((count-1)) directorios, $size"
        if confirm "¿Limpiar clones no usados hace >30 días? (find -mtime +30)" "N"; then
            find "$cache_dir/clone" -mindepth 1 -maxdepth 1 -type d -mtime +30 -print 2>/dev/null | while read -r d; do log "    borrando $d"; done
            find "$cache_dir/clone" -mindepth 1 -maxdepth 1 -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
            ok "Clones viejos limpiados"
        else
            info "Clones conservados"
        fi
    fi
    record "paru_cache" "OK"
}

check_orphans() {  # (9)
    step "Limpieza — paquetes huérfanos (pacman -Qtd)"
    local orphans
    orphans=$(pacman -Qtdq 2>/dev/null || true)
    if [[ -z "$orphans" ]]; then
        ok "Sin huérfanos"
        record "orphans" "OK"
        return 0
    fi
    local count
    count=$(echo "$orphans" | wc -l)
    warn_msg "$count huérfano(s) detectado(s):"
    echo "$orphans" | while read -r p; do log "    $p"; done
    # mostrar detalle
    pacman -Qtd 2>/dev/null | head -n 20 | while read -r l; do log "    $l"; done
    log "    ${C_DIM}(Revisa: pacman -Qtd — Arch recomienda no borrar a ciegas)${C_RESET}"
    record "orphans" "WARN" "$count huérfano(s)"
    if confirm "¿Eliminar huérfanos ahora? (pacman -Rns)" "N"; then
        if ! sudo -n true 2>/dev/null; then
            fail "No se pudieron eliminar huérfanos — sudo no disponible"
            record "orphans" "FAIL" "sin sudo"
            return 1
        fi
        # shellcheck disable=SC2046
        if sudo pacman -Rns $(pacman -Qtdq) 2>&1 | tee -a "$LOGFILE"; then
            ok "Huérfanos eliminados"
            record "orphans" "OK" "eliminados"
        else
            fail "No se pudieron eliminar huérfanos"
            record "orphans" "FAIL"
            return 1
        fi
    else
        info "Huérfanos conservados"
    fi
}

vacuum_journal() {  # (35)
    step "Limpieza — journal (vacuum-time=$JOURNAL_KEEP)"
    if ! need_cmd journalctl; then
        skip "journalctl no disponible"
        record "journal" "SKIP"
        return 0
    fi
    if ! sudo -n true 2>/dev/null; then
        skip "journal vacuum omitido — sudo no disponible"
        record "journal" "SKIP" "sin sudo"
        return 0
    fi
    local before after
    before=$(journalctl --disk-usage 2>/dev/null | grep -oE "[0-9.]+[KMGT]B" | head -1 || echo "?")
    info "Tamaño antes: $before"
    if sudo journalctl --vacuum-time="$JOURNAL_KEEP" 2>&1 | tee -a "$LOGFILE"; then
        after=$(journalctl --disk-usage 2>/dev/null | grep -oE "[0-9.]+[KMGT]B" | head -1 || echo "?")
        ok "Journal vacuum OK (antes $before → ahora $after)"
        record "journal" "OK" "$before → $after"
    else
        fail "journal vacuum falló"
        record "journal" "FAIL"
        return 1
    fi
}

# ─────────────────────────────────────────────
# Summary (38)
# ─────────────────────────────────────────────
show_summary() {
    separator
    section "RESUMEN"
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
        log "  ${C_RED}${C_BOLD}Algunas tareas fallaron — revisa el log: $LOGFILE${C_RESET}"
    elif [[ $has_warn -eq 1 ]]; then
        log "  ${C_YELLOW}Completado con advertencias — revisa arriba.${C_RESET}"
    else
        log "  ${C_GREEN}${C_BOLD}Todo OK${C_RESET}"
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
    section "ACTUALIZACIONES"
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
    section "LIMPIEZA"
    show_cache_usage || true
    # cada limpieza pregunta; no es destructiva sin confirmar (salvo paccache/paru -Sc)
    if confirm "¿Limpiar caché pacman (paccache -rk$PACMAN_CACHE_KEEP)?" "N"; then
        cleanup_pacman_cache || true
    else
        skip "caché pacman conservada"
        record "pacman_cache" "SKIP" "usuario omitió"
    fi
    cleanup_paru_cache || true
    check_orphans || true
    if confirm "¿Vacuum journal (--vacuum-time=$JOURNAL_KEEP)?" "N"; then
        vacuum_journal || true
    else
        skip "journal conservado"
        record "journal" "SKIP" "usuario omitió"
    fi
}

run_health() {
    section "HEALTH CHECK"
    check_disk_space || true
    check_package_integrity || true
    check_pacnew || true
    check_reboot_required || true
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

# ─────────────────────────────────────────────
# Interactive menu (42)
# ─────────────────────────────────────────────
interactive_menu() {
    # Ctrl+C cancela la tarea actual y vuelve al menú; Ctrl+D/q sale.
    trap 'echo ""; warn_msg "Interrumpido — volviendo al menú…"' INT
    while true; do
        RESULTS=()
        ORDER=()
        header "SYSTEM UPDATE"
        cat <<'MENU'
  1) Full update              (paru + npm + uv + pipx)
  2) Dev tools                (uv + pipx)
  3) Cleanup                  (caché pacman/paru, huérfanos, journal)
  4) Health check             (disco, integridad, pacnew, reinicio, cachés)
  5) Full maintenance         (update + cleanup + health)
  6) Run everything           (update + cleanup + health + resumen)

  q) Quit
MENU
        echo ""
        local choice
        if ! read -r -p "$(echo -e "${C_CYAN}Select an option: ${C_RESET}")" choice; then
            log "Saliendo (EOF/Ctrl-D)."
            exit 0
        fi
        case "$choice" in
            1) run_updates; show_summary; send_notify "System Update" "Full update terminado" ;;
            2) run_devtools; show_summary; send_notify "System Update" "Dev tools terminados" ;;
            3) run_cleanup; show_summary; send_notify "System Update" "Cleanup terminado" ;;
            4) run_health; show_summary ;;
            5) run_full_maintenance; show_summary; send_notify "System Update" "Full maintenance terminado" ;;
            6) run_everything; show_summary; send_notify "System Update" "Run everything terminado" ;;
            q|Q) log "Saliendo."; exit 0 ;;
            *) warn_msg "Opción inválida: $choice" ;;
        esac
        echo ""
        # Pausa que respeta Ctrl+C y q para salir
        local _ans
        if ! read -r -p "$(echo -e "${C_DIM}Press ENTER para volver al menú (q para salir)…${C_RESET} ")" _ans; then
            exit 0
        fi
        [[ "${_ans,,}" == "q" ]] && exit 0
    done
}

print_help() {
    cat <<EOF
system-update — updater modular para Arch + Hyprland

Uso: $(basename "$0") [opción]

Opciones:
  (sin args)   menú interactivo
  --all, -a    corre todo (update + cleanup + health) sin menú
  --update     solo full update (paru, npm, uv, pipx)
  --dev        solo dev tools (uv, pipx)
  --cleanup    solo limpieza
  --health     solo health check
  --help, -h   esta ayuda

Variables de entorno:
  JOURNAL_KEEP=30d        días a conservar en journal vacuum
  PACMAN_CACHE_KEEP=2     versiones a mantener en paccache

Log: \$LOGDIR/update-*.log  (actual: $LOGFILE)
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
                send_notify "System Update — FAIL" "Algunas tareas fallaron. Log: $LOGFILE" critical
            else
                send_notify "System Update — OK" "Run everything completado"
            fi
            handle_post_failure --all
            pause_before_close
            ;;
        --update)
            ensure_sudo || true
            header "FULL UPDATE"
            run_updates; show_summary
            send_notify "System Update" "Full update terminado"
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
            ensure_sudo || true
            interactive_menu
            ;;
        *)
            echo "Opción desconocida: $1" >&2
            print_help
            exit 1
            ;;
    esac
}

main "$@"
