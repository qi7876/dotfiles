#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test_root=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-test.XXXXXX")
trap 'rm -rf "$test_root"' EXIT HUP INT TERM

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

assert_link() {
    test -L "$1" || fail "$1 is not a symbolic link"
}

assert_managed() {
    resolved=$(realpath "$1")
    case "$resolved" in
        "$repo_dir"/*) ;;
        *) fail "$1 does not resolve into the dotfiles repository" ;;
    esac
}

home_dir="$test_root/home"
mkdir -p "$home_dir"

DOTFILES_TARGET="$home_dir" "$repo_dir/scripts/install.sh" shell git ssh

assert_link "$home_dir/.zshrc"
assert_link "$home_dir/.zprofile"
assert_link "$home_dir/.zshenv"
assert_managed "$home_dir/.config/git/config"
assert_link "$home_dir/.ssh/config"

secrets_file="$home_dir/.config/dotfiles/secrets.zsh"
ssh_local_file="$home_dir/.ssh/config.local"
test -f "$secrets_file" || fail "secrets file was not created"
test -f "$ssh_local_file" || fail "SSH local config was not created"
test "$(stat -f '%Lp' "$secrets_file" 2>/dev/null || stat -c '%a' "$secrets_file")" = 600 \
    || fail "secrets file permissions are not 600"

printf '%s\n' 'export TEST_SECRET=preserved' >"$secrets_file"
printf '%s\n' 'Host private-example' >"$ssh_local_file"
DOTFILES_TARGET="$home_dir" "$repo_dir/scripts/install.sh" shell git ssh
grep -q 'TEST_SECRET=preserved' "$secrets_file" || fail "secrets file was overwritten"
grep -q 'Host private-example' "$ssh_local_file" || fail "SSH local config was overwritten"

DOTFILES_TARGET="$home_dir" "$repo_dir/scripts/uninstall.sh" shell git ssh
test ! -L "$home_dir/.zshrc" || fail "shell link was not removed"
test ! -L "$home_dir/.ssh/config" || fail "SSH config link was not removed"
test -f "$secrets_file" || fail "uninstall removed the secrets file"
test -f "$ssh_local_file" || fail "uninstall removed the SSH local config"

conflict_home="$test_root/conflict-home"
mkdir -p "$conflict_home"
printf '%s\n' 'keep me' >"$conflict_home/.zshrc"
if DOTFILES_TARGET="$conflict_home" "$repo_dir/scripts/install.sh" shell >/dev/null 2>&1; then
    fail "install succeeded despite an existing file conflict"
fi
test "$(cat "$conflict_home/.zshrc")" = 'keep me' || fail "conflicting file was modified"

printf '%s\n' 'install integration tests passed'
