#!/usr/bin/env bash
# Interactive task selection menu

# Registry: id | label | function | default_checked
TASKS=(
    "preflight|Pre-flight system checks|run_preflight|1"
    "mirrors|Update mirrors (reflector)|update_reflector|0"
    "keys|Repair pacman keys|repair_pacman_keys|0"
    "system|Update system & AUR (paru)|update_system|1"
    "npm|Update npm packages|update_npm|0"
    "uv|Update uv tools|update_uv_tools|0"
    "pipx|Update pipx tools|update_pipx|0"
    "health|Post-flight health checks|run_postflight|1"
    "orphans|Check / remove orphans|check_orphans|0"
    "cache|Clean package caches (paccache)|cleanup_pacman_cache|0"
    "paru_cache|Clean paru clone cache|cleanup_paru_cache|0"
    "journal|Vacuum system journal|vacuum_journal|0"
)

run_selected() {
    local -n _sel_ref=$1
    local total=${#TASKS[@]}
    local i
    ensure_sudo || true
    for ((i=0; i<total; i++)); do
        if [[ ${_sel_ref[$i]} -eq 1 ]]; then
            local id fn
            IFS='|' read -r id _ fn _ <<< "${TASKS[$i]}"
            if ! "$fn" && [[ "$id" == "preflight" ]]; then
                fail "Pre-flight failed — aborting selected tasks"
                break
            fi
        fi
    done
    show_summary
    if has_failures; then
        send_notify "System Update — FAIL" "Some tasks failed. Log: $LOGFILE" critical
    else
        send_notify "System Update" "Selected tasks completed"
    fi
    save_log_prompt
}

interactive_menu() {
    local total=${#TASKS[@]}
    local -a sel=() labels=()
    local cur=0
    local i
    for ((i=0; i<total; i++)); do
        local _id _label _fn _def
        IFS='|' read -r _id _label _fn _def <<< "${TASKS[$i]}"
        labels+=("$_label")
        sel+=("${_def:-0}")
        [[ "$_id" == "system" ]] && cur=$i
    done

    local key c esc
    local icon_checked="󰄲"
    local icon_unchecked="󰄱"

    tput civis 2>/dev/null || true
    printf '\033[2J\033[H'

    while true; do
        printf '\033[H'
        echo -e "${C_BOLD}Select tasks to execute:${C_RESET}"
        echo ""
        for ((i=0; i<total; i++)); do
            local label="${labels[$i]}"
            if [[ ${sel[$i]} -eq 1 ]]; then
                c="${C_GREEN}${icon_checked}${C_RESET}"
            else
                c="${C_DIM}${icon_unchecked}${C_RESET}"
            fi
            if [[ $i -eq $cur ]]; then
                echo -e "  ${C_CYAN}${C_BOLD}❯ ${c}  ${label}${C_RESET}"
            else
                echo -e "    ${c}  ${label}"
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
        echo -e "${C_DIM}↑/↓ or j/k move   Space toggle   a toggle all   Enter apply/toggle   q quit${C_RESET}"
        printf '\033[J'

        IFS= read -rsn1 key || exit 0
        case "$key" in
            q|Q)
                tput cnorm 2>/dev/null || true
                exit 0
                ;;
            j|J)
                ((cur < total)) && ((cur++))
                ;;
            k|K)
                ((cur > 0)) && ((cur--))
                ;;
            a|A)
                local any_unset=0
                for ((i=0; i<total; i++)); do
                    [[ ${sel[i]} -eq 0 ]] && any_unset=1
                done
                for ((i=0; i<total; i++)); do
                    sel[i]=$any_unset
                done
                ;;
            " ")
                if [[ $cur -lt $total ]]; then
                    sel[cur]=$(( 1 - sel[cur] ))
                else
                    break
                fi
                ;;
            "")
                if [[ $cur -eq $total ]]; then
                    break
                fi
                sel[cur]=$(( 1 - sel[cur] ))
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

    run_selected sel
}
