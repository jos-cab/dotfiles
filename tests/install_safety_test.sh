#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
assert() { "$@" || fail "$*"; }
fixture() {
    local name=$1
    TEST_ROOT="$TMP/$name" HOME="$TMP/$name/home"
    unset INSTALL_FAIL_AFTER INSTALL_MKDIR_FAIL INSTALL_BACKUP_FAIL INSTALL_LINK_FAIL INSTALL_RESTORE_FAIL INSTALL_REMOVE_FAIL INSTALL_REAPPEAR_DEST INSTALL_REAPPEAR_CONTENT INSTALL_REPLACE_LINK INSTALL_REPLACE_TARGET
    export HOME SHELL=/bin/zsh
    mkdir -p "$TEST_ROOT" "$HOME"
    cp "$ROOT/install.sh" "$TEST_ROOT/install.sh"
    mkdir -p "$TEST_ROOT/kitty"
    printf 'new\n' > "$TEST_ROOT/kitty/kitty.conf"
}
run_install() {
    (cd "$TEST_ROOT" && env INSTALL_FAIL_AFTER="${INSTALL_FAIL_AFTER:-}" INSTALL_MKDIR_FAIL="${INSTALL_MKDIR_FAIL:-}" INSTALL_BACKUP_FAIL="${INSTALL_BACKUP_FAIL:-}" INSTALL_LINK_FAIL="${INSTALL_LINK_FAIL:-}" INSTALL_RESTORE_FAIL="${INSTALL_RESTORE_FAIL:-}" INSTALL_REMOVE_FAIL="${INSTALL_REMOVE_FAIL:-}" INSTALL_REAPPEAR_DEST="${INSTALL_REAPPEAR_DEST:-}" INSTALL_REAPPEAR_CONTENT="${INSTALL_REAPPEAR_CONTENT:-}" INSTALL_REPLACE_LINK="${INSTALL_REPLACE_LINK:-}" INSTALL_REPLACE_TARGET="${INSTALL_REPLACE_TARGET:-}" bash ./install.sh --yes) >/dev/null 2>&1
}
assert_content() { [ "$(cat "$1")" = "$2" ] || fail "unexpected content: $1"; }
fixture absent
run_install
assert test -L "$HOME/.config/kitty/kitty.conf"
fixture regular
mkdir -p "$HOME/.config/kitty"; printf old > "$HOME/.config/kitty/kitty.conf"
run_install
assert test -f "$HOME/.config/kitty/kitty.conf.bak"
assert test -L "$HOME/.config/kitty/kitty.conf"
fixture directory
mkdir -p "$HOME/.config/kitty/kitty.conf"; printf old > "$HOME/.config/kitty/kitty.conf/keep"
run_install
assert test -f "$HOME/.config/kitty/kitty.conf.bak/keep"
fixture valid_link
mkdir -p "$HOME/.config/kitty"; ln -s /dev/null "$HOME/.config/kitty/kitty.conf"
run_install
assert test -L "$HOME/.config/kitty/kitty.conf.bak"
fixture dangling_link
mkdir -p "$HOME/.config/kitty"; ln -s /missing "$HOME/.config/kitty/kitty.conf"
run_install
assert test -L "$HOME/.config/kitty/kitty.conf.bak"
fixture collision
mkdir -p "$HOME/.config/kitty"; : > "$HOME/.config/kitty/kitty.conf"; : > "$HOME/.config/kitty/kitty.conf.bak"
run_install
assert test -f "$HOME/.config/kitty/kitty.conf.bak.1"
fixture invalid_input
set +e
(cd "$TEST_ROOT" && printf 'x' | bash ./install.sh) >/dev/null 2>&1
status=$?
set -e
[ "$status" -ne 0 ] || fail 'invalid input accepted'
fixture noninteractive
set +e
(cd "$TEST_ROOT" && bash ./install.sh </dev/null) >/dev/null 2>&1
status=$?
set -e
[ "$status" -ne 0 ] || fail 'non-interactive install accepted'
fixture rollback
mkdir -p "$TEST_ROOT/hyprland"; printf x > "$TEST_ROOT/hyprland/a"; printf y > "$TEST_ROOT/hyprland/b"
mkdir -p "$HOME/.config/hypr"; printf old > "$HOME/.config/hypr/a"
INSTALL_FAIL_AFTER=3
set +e; run_install; status=$?; set -e
[ "$status" -ne 0 ] || fail 'injected failure succeeded'
assert test -f "$HOME/.config/hypr/a"
assert test ! -e "$HOME/.config/hypr/a.bak"
fixture restore_failure
mkdir -p "$HOME/.config/kitty"; printf old > "$HOME/.config/kitty/kitty.conf"
INSTALL_FAIL_AFTER=1
set +e
output=$(cd "$TEST_ROOT" && INSTALL_FAIL_AFTER=1 INSTALL_RESTORE_FAIL="$HOME/.config/kitty/kitty.conf" bash ./install.sh --yes 2>&1)
status=$?
set -e
[ "$status" -ne 0 ] || fail 'restore-failure injection succeeded'
printf '%s' "$output" | grep -F "Manual recovery required for: $HOME/.config/kitty/kitty.conf (backup: $HOME/.config/kitty/kitty.conf.bak)" >/dev/null || fail 'manual recovery path not reported'
assert test -f "$HOME/.config/kitty/kitty.conf.bak"
fixture symlink_parent
outside="$TMP/outside"; mkdir "$outside"; ln -s "$outside" "$HOME/.config"
set +e; run_install; status=$?; set -e
[ "$status" -ne 0 ] || fail 'symlinked parent accepted'
assert test ! -e "$outside/kitty"
fixture mkdir_failure
INSTALL_MKDIR_FAIL="$HOME/.config"
set +e; run_install; status=$?; set -e
[ "$status" -ne 0 ] || fail 'mkdir failure accepted'
assert test ! -e "$HOME/.config"
fixture backup_failure
mkdir -p "$HOME/.config/kitty"; printf old > "$HOME/.config/kitty/kitty.conf"
INSTALL_BACKUP_FAIL="$HOME/.config/kitty/kitty.conf"
set +e; run_install; status=$?; set -e
[ "$status" -ne 0 ] || fail 'backup failure accepted'
assert_content "$HOME/.config/kitty/kitty.conf" old
fixture link_failure
INSTALL_LINK_FAIL="$HOME/.config/kitty/kitty.conf"
set +e; run_install; status=$?; set -e
[ "$status" -ne 0 ] || fail 'link failure accepted'
assert test ! -e "$HOME/.config/kitty/kitty.conf"
fixture remove_failure
mkdir -p "$HOME/.config/kitty"; printf old > "$HOME/.config/kitty/kitty.conf"
INSTALL_FAIL_AFTER=1 INSTALL_REMOVE_FAIL="$HOME/.config/kitty/kitty.conf"
set +e; run_install; status=$?; set -e
[ "$status" -ne 0 ] || fail 'remove failure setup succeeded'
assert test -L "$HOME/.config/kitty/kitty.conf"
assert test -f "$HOME/.config/kitty/kitty.conf.bak"
fixture reappearing_destination
mkdir -p "$HOME/.config/kitty"; printf old > "$HOME/.config/kitty/kitty.conf"
INSTALL_FAIL_AFTER=1 INSTALL_REAPPEAR_DEST="$HOME/.config/kitty/kitty.conf" INSTALL_REAPPEAR_CONTENT=reappeared
set +e
output=$(cd "$TEST_ROOT" && env INSTALL_FAIL_AFTER=1 INSTALL_REAPPEAR_DEST="$HOME/.config/kitty/kitty.conf" INSTALL_REAPPEAR_CONTENT=reappeared bash ./install.sh --yes 2>&1)
status=$?
set -e
[ "$status" -ne 0 ] || fail 'reappearance setup succeeded'
assert_content "$HOME/.config/kitty/kitty.conf" reappeared
assert_content "$HOME/.config/kitty/kitty.conf.bak" old
printf '%s' "$output" | grep -F "$HOME/.config/kitty/kitty.conf (new destination) and $HOME/.config/kitty/kitty.conf.bak (backup)" >/dev/null || fail 'reappearance recovery not reported'
fixture multiple_recovery_failures
mkdir -p "$TEST_ROOT/hyprland" "$HOME/.config/hypr"; printf olda > "$HOME/.config/hypr/a"; printf oldb > "$HOME/.config/hypr/b"; printf a > "$TEST_ROOT/hyprland/a"; printf b > "$TEST_ROOT/hyprland/b"
INSTALL_FAIL_AFTER=3 INSTALL_RESTORE_FAIL="$HOME/.config/hypr/a"
set +e; run_install; status=$?; set -e
[ "$status" -ne 0 ] || fail 'multiple recovery setup succeeded'
assert test -f "$HOME/.config/hypr/a.bak"
assert_content "$HOME/.config/hypr/b" oldb
fixture changed_link
INSTALL_FAIL_AFTER=1 INSTALL_REPLACE_LINK="$HOME/.config/kitty/kitty.conf" INSTALL_REPLACE_TARGET=/replacement
set +e; run_install; status=$?; set -e
[ "$status" -ne 0 ] || fail 'changed link setup succeeded'
assert test -L "$HOME/.config/kitty/kitty.conf"
[ "$(readlink "$HOME/.config/kitty/kitty.conf")" = /replacement ] || fail 'replacement link removed'
fixture two_restore_failures
mkdir -p "$TEST_ROOT/hyprland" "$HOME/.config/hypr"; printf olda > "$HOME/.config/hypr/a"; printf oldb > "$HOME/.config/hypr/b"; printf a > "$TEST_ROOT/hyprland/a"; printf b > "$TEST_ROOT/hyprland/b"
set +e
output=$(cd "$TEST_ROOT" && env INSTALL_FAIL_AFTER=3 INSTALL_RESTORE_FAIL="$HOME/.config/hypr/a,$HOME/.config/hypr/b" bash ./install.sh --yes 2>&1)
status=$?
set -e
[ "$status" -ne 0 ] || fail 'two restore failures setup succeeded'
assert test -f "$HOME/.config/hypr/a.bak"
assert test -f "$HOME/.config/hypr/b.bak"
printf '%s' "$output" | grep -F "$HOME/.config/hypr/a (backup: $HOME/.config/hypr/a.bak)" >/dev/null || fail 'first recovery missing'
printf '%s' "$output" | grep -F "$HOME/.config/hypr/b (backup: $HOME/.config/hypr/b.bak)" >/dev/null || fail 'second recovery missing'
fixture multi_mutation_rollback
mkdir -p "$TEST_ROOT/hyprland" "$HOME/.config/hypr"; printf olda > "$HOME/.config/hypr/a"; printf oldb > "$HOME/.config/hypr/b"; printf a > "$TEST_ROOT/hyprland/a"; printf b > "$TEST_ROOT/hyprland/b"
INSTALL_FAIL_AFTER=3
set +e; run_install; status=$?; set -e
[ "$status" -ne 0 ] || fail 'multi mutation failure setup succeeded'
assert_content "$HOME/.config/hypr/a" olda
assert_content "$HOME/.config/hypr/b" oldb
assert test ! -e "$HOME/.config/hypr/a.bak"
assert test ! -e "$HOME/.config/hypr/b.bak"
fixture signal_int
mkdir -p "$TEST_ROOT/hyprland"; printf a > "$TEST_ROOT/hyprland/a"; printf b > "$TEST_ROOT/hyprland/b"
set +e
(cd "$TEST_ROOT" && env INSTALL_SIGNAL_AFTER=1 INSTALL_SIGNAL_KIND=INT bash ./install.sh --yes >/dev/null 2>&1)
status=$?
set -e
[ "$status" -ne 0 ] || fail 'SIGINT setup succeeded'
assert test ! -e "$HOME/.config"
fixture signal_term
mkdir -p "$TEST_ROOT/hyprland"; printf a > "$TEST_ROOT/hyprland/a"; printf b > "$TEST_ROOT/hyprland/b"
set +e
(cd "$TEST_ROOT" && env INSTALL_SIGNAL_AFTER=1 INSTALL_SIGNAL_KIND=TERM bash ./install.sh --yes >/dev/null 2>&1)
status=$?
set -e
[ "$status" -ne 0 ] || fail 'SIGTERM setup succeeded'
assert test ! -e "$HOME/.config"
printf 'ok: install safety tests\n'
