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

    for operation in ver status get delay; do
        failure_output_file="${TMPDIR:-/tmp}/dotfiles-mh-query-failure.$$"
        trap 'rm -f "$failure_output_file"' EXIT HUP INT TERM
        if zsh -c '
            source "$1"
            _mhcurl() { return 23 }
            case "$2" in
                ver) mh-ver ;;
                status) mh-status ;;
                get) mh-get-group group ;;
                delay) mh-delay-group group ;;
            esac
        ' zsh "$config" "$operation" >"$failure_output_file" 2>/dev/null; then
            fail "shell-$platform hid a failed $operation query"
        fi
        test ! -s "$failure_output_file" \
            || fail "shell-$platform emitted output for a failed $operation query"
        rm -f "$failure_output_file"
        trap - EXIT HUP INT TERM
    done

    for operation in ver status get delay; do
        success_output=$(zsh -c '
            source "$1"
            operation=$2
            _mhcurl() {
                case "$operation" in
                    ver) print '\''{"version":"1.0"}'\'' ;;
                    status) print '\''{"proxies":{"group":{"now":"proxy"},"direct":{"now":null}}}'\'' ;;
                    get) print '\''{"name":"group"}'\'' ;;
                    delay) print '\''{"proxy":12}'\'' ;;
                esac
            }
            case "$2" in
                ver) mh-ver ;;
                status) mh-status ;;
                get) mh-get-group group ;;
                delay) mh-delay-group group ;;
            esac
        ' zsh "$config" "$operation" 2>/dev/null)
        case "$operation:$success_output" in
            'ver:'*'"version": "1.0"'*) ;;
            'status:group -> proxy') ;;
            'get:'*'"name": "group"'*) ;;
            'delay:'*'"proxy": 12'*) ;;
            *) fail "shell-$platform changed successful $operation output" ;;
        esac
    done

    for operation in get set delay update reload; do
        marker_file="${TMPDIR:-/tmp}/dotfiles-mh-api-marker.$$"
        rm -f "$marker_file"
        trap 'rm -f "$marker_file"' EXIT HUP INT TERM
        if MARKER_FILE="$marker_file" zsh -c '
            source "$1"
            jq() { return 24 }
            _mhcurl() { print called >>"$MARKER_FILE"; return 0 }
            case "$2" in
                get) mh-get-group group ;;
                set) mh-set-group-proxy group proxy ;;
                delay) mh-delay-group group ;;
                update) mh-update-provider provider ;;
                reload) MIHOMO_CONFIG=/tmp/config mh-reload ;;
            esac
        ' zsh "$config" "$operation" >/dev/null 2>&1; then
            fail "shell-$platform hid a jq failure during $operation"
        fi
        test ! -e "$marker_file" \
            || fail "shell-$platform called the API after jq failed during $operation"
        trap - EXIT HUP INT TERM
    done
done

macos_path=$(PATH="/usr/bin:/bin:$HOME/.local/bin:/usr/bin" zsh -f -c '
    source "$1"
    source "$1"
    print -l -- $path
' zsh "$repo_dir/shell-macos/.zshenv")
expected_macos_path=$(printf '%s\n' \
    "$HOME/.local/bin" \
    /opt/homebrew/opt/node@24/bin \
    "$HOME/.cargo/bin" \
    /opt/homebrew/opt/rustup/bin \
    /usr/bin \
    /bin)
test "$macos_path" = "$expected_macos_path" \
    || fail "macOS path order or uniqueness is incorrect"

linux_path=$(PATH="/usr/bin:/bin:$HOME/.cargo/bin:/usr/bin" zsh -f -c '
    source "$1"
    source "$1"
    print -l -- $path
' zsh "$repo_dir/shell-linux/.zshenv")
expected_linux_path=$(printf '%s\n' \
    "$HOME/.local/bin" \
    "$HOME/.cargo/bin" \
    /usr/bin \
    /bin)
test "$linux_path" = "$expected_linux_path" \
    || fail "Linux path order or uniqueness is incorrect"

printf '%s\n' 'Zsh behavior tests passed'
