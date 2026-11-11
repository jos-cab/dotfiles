#!/usr/bin/env bash
# Common configuration, logging, process control, and utilities

set -uo pipefail

# ─────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────
JOURNAL_KEEP="${JOURNAL_KEEP:-30d}"
PACMAN_CACHE_KEEP="${PACMAN_CACHE_KEEP:-2}"
LOCKFILE="${XDG_RUNTIME_DIR:-/tmp}/system-update.lock"
LOGDIR="${XDG_STATE_HOME:-$HOME/.local/state}/system-update"
LOGFILE="$LOGDIR/update-$(date +%Y-%m-%d_%H%M%S).log"
KEEP_LOG=0
AUTO_CONFIRM=1
# shellcheck disable=SC2034 # Used by lib/checks.sh
DISK_WARN_THRESHOLD=90
# shellcheck disable=SC2034 # Used by lib/checks.sh
DISK_CRIT_THRESHOLD=95

init_logging() {
    mkdir -p "$LOGDIR" 2>/dev/null || true
    # shellcheck disable=SC2012 # Sorting by mtime for log rotation
    ls -1t "$LOGDIR"/update-*.log 2>/dev/null | tail -n +11 | xargs -r rm -f 2>/dev/null || true
}

# ─────────────────────────────────────────────
# UI Formatting / Colors
# ─────────────────────────────────────────────
# shellcheck disable=SC2034 # Terminal color palette variables used across modules
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

declare -A RESULTS=()
ORDER=()

# ─────────────────────────────────────────────
# Unified Cleanup & Traps
# ─────────────────────────────────────────────
SUDO_PID=""

cleanup() {
    local rc=$?
    if [[ -n "${SUDO_PID:-}" ]] && kill -0 "$SUDO_PID" 2>/dev/null; then
        kill "$SUDO_PID" 2>/dev/null || true
    fi
    [[ -t 1 ]] && tput cnorm 2>/dev/null || true
    if [[ ${KEEP_LOG:-0} -eq 0 && -f "${LOGFILE:-}" ]]; then
        rm -f "$LOGFILE" 2>/dev/null || true
    fi
    exit "$rc"
}

trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

# ─────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────
log() {
    printf '%s\n' "$*"
    printf '%s\n' "$*" | sed -E 's/\x1b(\(B|\[[0-9;]*[a-zA-Z])//g' >> "$LOGFILE"
}

log_plain() {
    printf '%s\n' "$*" | sed -E 's/\x1b(\(B|\[[0-9;]*[a-zA-Z])//g' >> "$LOGFILE"
}

log_block() {
    sed -E 's/\x1b(\(B|\[[0-9;]*[a-zA-Z])//g' >> "$LOGFILE"
}

header() {
    local title="${1:-SYSTEM UPDATE}"
    local width=38
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
    local line="── ${title} "
    local cols=42
    local fill=$(( cols - ${#line} ))
    (( fill < 0 )) && fill=0
    echo ""
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
    [[ " ${ORDER[*]} " == *" $key "* ]] || ORDER+=("$key")
}

has_failures() {
    local k
    for k in "${!RESULTS[@]}"; do
        [[ "${RESULTS[$k]}" == FAIL* ]] && return 0
    done
    return 1
}

# ─────────────────────────────────────────────
# Utilities & Process Management
# ─────────────────────────────────────────────
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
    if ! read -r -p "$(printf '%s ' "${C_YELLOW}$prompt${C_RESET}")" ans; then
        echo ""
        return 1
    fi
    ans="${ans:-$def}"
    if [[ "$ans" =~ ^[qQ]$ ]]; then
        log "Aborted by user (q)."
        exit 0
    fi
    [[ "$ans" =~ ^[Yy]$ ]]
}

acquire_lock() {
    exec 200>"$LOCKFILE" || { fail "Could not open lockfile $LOCKFILE"; exit 1; }
    if ! flock -n 200; then
        fail "Another instance of system-update is already running (lock $LOCKFILE)"
        exit 1
    fi
}

ensure_sudo() {
    if [[ -z "${SUDO_PID:-}" ]] || ! kill -0 "$SUDO_PID" 2>/dev/null; then
        step "Authenticating sudo"
        if ! sudo -v; then
            fail "Could not authenticate sudo"
            return 1
        fi
        ( while true; do sudo -n true; sleep 50 & wait $!; kill -0 "$$" 2>/dev/null || exit; done ) 200>&- &
        SUDO_PID=$!
        ok "sudo authenticated (keep-alive PID $SUDO_PID)"
    fi
    return 0
}

sudo_run() {
    if sudo -n true 2>/dev/null; then
        sudo "$@"
        return $?
    fi
    if [[ ! -t 0 ]]; then
        return 1
    fi
    if sudo -v; then
        sudo "$@"
        return $?
    fi
    return 1
}

send_notify() {
    local title="$1" body="$2" urgency="${3:-normal}"
    if need_cmd notify-send; then
        notify-send -u "$urgency" -a "system-update" "$title" "$body" 2>/dev/null || true
    fi
    log_plain "[notify] $title — $body"
}

save_log_prompt() {
    local def="N" hint="[y/N]" ans
    if has_failures; then def="Y"; hint="[Y/n]"; fi
    read -r -p "$(printf '%s ' "${C_YELLOW}Save log to $LOGFILE? $hint${C_RESET}")" ans || ans="$def"
    ans="${ans:-$def}"
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        KEEP_LOG=1
        log "Log saved: $LOGFILE"
    else
        KEEP_LOG=0
        rm -f "$LOGFILE" 2>/dev/null || true
    fi
}

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
            INFO) log "  ${C_DIM}${ICON_INFO}  ${C_BOLD}$(printf "%-16s" "$key")${C_RESET} ${C_CYAN}INFO${C_RESET}${msg:+ ${C_DIM}$msg${C_RESET}}";;
            WARN) log "  ${C_YELLOW}${ICON_WARN}  $(printf "%-16s" "$key") ${C_YELLOW}WARN${C_RESET}${msg:+ ${C_DIM}$msg${C_RESET}}"; has_warn=1;;
            FAIL) log "  ${C_RED}${ICON_FAIL}  $(printf "%-16s" "$key") ${C_RED}FAIL${C_RESET}${msg:+ $msg}"; has_fail=1;;
            *)    log "  $key: $val";;
        esac
    done
    echo ""
    if [[ $has_fail -eq 1 ]]; then
        KEEP_LOG=1
        log "  ${C_RED}${C_BOLD}Some tasks failed — check log: $LOGFILE${C_RESET}"
    elif [[ $has_warn -eq 1 ]]; then
        log "  ${C_YELLOW}Completed with warnings — see above.${C_RESET}"
    else
        log "  ${C_GREEN}${C_BOLD}All OK${C_RESET}"
    fi
    echo ""
}
