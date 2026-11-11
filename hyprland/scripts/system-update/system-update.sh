#!/usr/bin/env bash
# ─────────────────────────────────────────────
# system-update — Arch + Hyprland modular updater
# ─────────────────────────────────────────────

set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")" &>/dev/null && pwd)"

# Source modules
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=lib/checks.sh
source "$SCRIPT_DIR/lib/checks.sh"
# shellcheck source=lib/updates.sh
source "$SCRIPT_DIR/lib/updates.sh"
# shellcheck source=lib/cleanup.sh
source "$SCRIPT_DIR/lib/cleanup.sh"
# shellcheck source=lib/menu.sh
source "$SCRIPT_DIR/lib/menu.sh"

run_everything() {
    if ! run_preflight; then
        fail "Pre-flight failed — skipping updates"
        return 1
    fi
    run_updates || true
    run_postflight || true
    run_cleanup || true
}

print_help() {
    cat <<EOF
system-update — modular updater for Arch + Hyprland

Usage: $(basename "$0") [option]

Options:
  (no args)        selectable task menu
  --all, -a        run everything (pre-flight + update + post-flight + cleanup)
  --update, -u     full updates (paru, npm, uv, pipx)
  --dev            dev tools only (uv, pipx)
  --cleanup, -c    cleanup only (caches, orphans, journal)
  --health         pre-flight and post-flight health checks only
  --check          non-interactive check (pending updates count for waybar/timers)
  --help, -h       show this help

Environment variables:
  JOURNAL_KEEP=30d        days to keep in journal vacuum
  PACMAN_CACHE_KEEP=2     versions to keep in paccache

Log: \$LOGDIR/update-*.log  (current: $LOGFILE)
Lock: $LOCKFILE
EOF
}

main() {
    # 1. Early handling of --help, unknown options and --check (no GUI relaunch, no lock)
    case "${1:-}" in
        --help|-h)
            print_help
            exit 0
            ;;
        --check)
            count_pending_updates
            exit 0
            ;;
        --all|-a|--update|-u|--dev|--cleanup|-c|--health|"")
            ;;
        *)
            echo "Unknown option: $1" >&2
            print_help
            exit 1
            ;;
    esac

    # 2. Relaunch in kitty if invoked from GUI launcher without TTY (before lock and before log initialization)
    if [[ ! -t 0 ]] && [[ ! -t 1 ]] && [[ -n "${WAYLAND_DISPLAY:-${DISPLAY:-}}" ]]; then
        if need_cmd kitty && [[ -z "${SYSTEM_UPDATE_RELAUNCHED:-}" ]]; then
            export SYSTEM_UPDATE_RELAUNCHED=1
            exec kitty -e "$0" "$@"
        fi
    fi

    # 3. Guard for interactive terminal
    if [[ ! -t 0 ]]; then
        echo "system-update needs an interactive terminal (stdin is not a TTY)." >&2
        exit 1
    fi

    # 4. Initialize logging directory and log rotation
    init_logging

    # 5. Acquire lock & write initial log header
    acquire_lock

    {
        echo "=== system-update $(date -Is) ==="
        echo "host: $(cat /etc/hostname 2>/dev/null || echo unknown)  user: $(whoami)  kernel: $(uname -r)"
        echo "args: $*"
        echo ""
    } >> "$LOGFILE"

    case "${1:-}" in
        --all|-a)
            ensure_sudo || true
            header "RUN EVERYTHING"
            run_everything
            show_summary
            if has_failures; then
                send_notify "System Update — FAIL" "Some tasks failed. Log: $LOGFILE" critical
            else
                send_notify "System Update — OK" "Full maintenance completed"
            fi
            save_log_prompt
            ;;
        --update|-u)
            ensure_sudo || true
            header "FULL UPDATE"
            if ! run_preflight; then
                fail "Pre-flight failed — skipping updates"
                show_summary
                send_notify "System Update — FAIL" "Pre-flight failed. Log: $LOGFILE" critical
                save_log_prompt
                exit 1
            fi
            run_updates
            run_postflight || true
            show_summary
            send_notify "System Update" "Update completed"
            save_log_prompt
            ;;
        --dev)
            header "DEV TOOLS"
            run_devtools
            show_summary
            save_log_prompt
            ;;
        --cleanup|-c)
            ensure_sudo || true
            header "CLEANUP"
            run_cleanup
            show_summary
            save_log_prompt
            ;;
        --health)
            ensure_sudo || true
            header "HEALTH CHECK"
            run_preflight || true
            run_postflight || true
            show_summary
            save_log_prompt
            ;;
        "")
            interactive_menu
            ;;
    esac

    has_failures && exit 1
    exit 0
}

main "$@"
