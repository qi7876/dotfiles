#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

for platform in macos linux; do
    config="$repo_dir/shell-$platform/.zshrc"

    success_output=$(zsh -c '
        source "$1"
        _mhcurl() { return 0 }
        mh-update-provider example
    ' zsh "$config" 2>/dev/null)
    test "$success_output" = 'Updated: example' \
        || fail "shell-$platform did not report a successful provider update"

    failure_output_file="${TMPDIR:-/tmp}/dotfiles-mh-failure.$$"
    trap 'rm -f "$failure_output_file"' EXIT HUP INT TERM
    if zsh -c '
        source "$1"
        _mhcurl() { return 23 }
        mh-update-provider example
    ' zsh "$config" >"$failure_output_file" 2>/dev/null; then
        fail "shell-$platform hid a failed provider update"
    fi
    test ! -s "$failure_output_file" \
        || fail "shell-$platform printed success for a failed provider update"
    rm -f "$failure_output_file"
    trap - EXIT HUP INT TERM
done

printf '%s\n' 'Zsh behavior tests passed'
