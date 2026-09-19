#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

for platform in macos linux; do
    config="$repo_dir/shell-$platform/.zshrc"

    for operation in update set reload; do
        case "$operation" in
            update) expected='Updated: example' ;;
            set) expected='group -> proxy' ;;
            reload) expected='mihomo config reloaded' ;;
        esac

        success_output=$(zsh -c '
            source "$1"
            _mhcurl() { return 0 }
            case "$2" in
                update) mh-update-provider example ;;
                set) mh-set-group-proxy group proxy ;;
                reload) MIHOMO_CONFIG=/tmp/config mh-reload ;;
            esac
        ' zsh "$config" "$operation" 2>/dev/null)
        test "$success_output" = "$expected" \
            || fail "shell-$platform did not report a successful $operation"

        failure_output_file="${TMPDIR:-/tmp}/dotfiles-mh-failure.$$"
        trap 'rm -f "$failure_output_file"' EXIT HUP INT TERM
        if zsh -c '
            source "$1"
            _mhcurl() { return 23 }
            case "$2" in
                update) mh-update-provider example ;;
                set) mh-set-group-proxy group proxy ;;
                reload) MIHOMO_CONFIG=/tmp/config mh-reload ;;
            esac
        ' zsh "$config" "$operation" >"$failure_output_file" 2>/dev/null; then
            fail "shell-$platform hid a failed $operation"
        fi
        test ! -s "$failure_output_file" \
            || fail "shell-$platform printed success for a failed $operation"
        rm -f "$failure_output_file"
        trap - EXIT HUP INT TERM
    done
done

printf '%s\n' 'Zsh behavior tests passed'
