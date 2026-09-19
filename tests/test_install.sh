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

fake_uname() {
    fake_dir=$1
    kernel_name=$2
    mkdir -p "$fake_dir"
    printf '%s\n' '#!/bin/sh' "printf '%s\\n' '$kernel_name'" >"$fake_dir/uname"
    chmod +x "$fake_dir/uname"
}

home_dir="$test_root/home"
mkdir -p "$home_dir"
darwin_bin="$test_root/darwin-bin"
fake_uname "$darwin_bin" Darwin

PATH="$darwin_bin:$PATH" DOTFILES_TARGET="$home_dir" "$repo_dir/scripts/install.sh" shell git ssh

assert_link "$home_dir/.zshrc"
assert_link "$home_dir/.zprofile"
assert_link "$home_dir/.zshenv"
case "$(realpath "$home_dir/.zshrc")" in
    "$repo_dir/shell-macos/"*) ;;
    *) fail "Darwin did not select shell-macos" ;;
esac
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
PATH="$darwin_bin:$PATH" DOTFILES_TARGET="$home_dir" "$repo_dir/scripts/install.sh" shell git ssh
grep -q 'TEST_SECRET=preserved' "$secrets_file" || fail "secrets file was overwritten"
grep -q 'Host private-example' "$ssh_local_file" || fail "SSH local config was overwritten"

PATH="$darwin_bin:$PATH" DOTFILES_TARGET="$home_dir" "$repo_dir/scripts/uninstall.sh" shell git ssh
test ! -L "$home_dir/.zshrc" || fail "shell link was not removed"
test ! -L "$home_dir/.ssh/config" || fail "SSH config link was not removed"
test -f "$secrets_file" || fail "uninstall removed the secrets file"
test -f "$ssh_local_file" || fail "uninstall removed the SSH local config"

conflict_home="$test_root/conflict-home"
mkdir -p "$conflict_home"
printf '%s\n' 'keep me' >"$conflict_home/.zshrc"
if PATH="$darwin_bin:$PATH" DOTFILES_TARGET="$conflict_home" \
    "$repo_dir/scripts/install.sh" shell >/dev/null 2>&1; then
    fail "install succeeded despite an existing file conflict"
fi
test "$(cat "$conflict_home/.zshrc")" = 'keep me' || fail "conflicting file was modified"

linux_home="$test_root/linux-home"
linux_bin="$test_root/linux-bin"
mkdir -p "$linux_home"
fake_uname "$linux_bin" Linux
PATH="$linux_bin:$PATH" DOTFILES_TARGET="$linux_home" "$repo_dir/scripts/install.sh" shell
case "$(realpath "$linux_home/.zshrc")" in
    "$repo_dir/shell-linux/"*) ;;
    *) fail "Linux did not select shell-linux" ;;
esac
PATH="$linux_bin:$PATH" DOTFILES_TARGET="$linux_home" "$repo_dir/scripts/install.sh" shell

default_home="$test_root/default-home"
mkdir -p "$default_home"
PATH="$darwin_bin:$PATH" DOTFILES_TARGET="$default_home" "$repo_dir/scripts/install.sh"
case "$(realpath "$default_home/.zshrc")" in
    "$repo_dir/shell-macos/"*) ;;
    *) fail "default install did not select shell-macos on Darwin" ;;
esac

unsupported_home="$test_root/unsupported-home"
unsupported_bin="$test_root/unsupported-bin"
mkdir -p "$unsupported_home"
fake_uname "$unsupported_bin" FreeBSD
if PATH="$unsupported_bin:$PATH" DOTFILES_TARGET="$unsupported_home" \
    "$repo_dir/scripts/install.sh" shell >/dev/null 2>&1; then
    fail "unsupported platform was accepted"
fi
test ! -e "$unsupported_home/.zshrc" || fail "unsupported platform created a shell link"
test ! -e "$unsupported_home/.config/dotfiles/secrets.zsh" \
    || fail "unsupported platform created a local secrets file"

printf '%s\n' 'install integration tests passed'
