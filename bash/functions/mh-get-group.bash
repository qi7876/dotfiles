# Keep pipeline failure handling local to this function.
mh-get-group() (
        set -o pipefail
        if [ -z "${1:-}" ]; then
                printf 'usage: mh-get-group <group>\n' >&2
                return 1
        fi
        encoded=$(printf '%s' "$1" | jq -sRr @uri) || return $?
        _mhcurl "$MIHOMO_API/proxies/$encoded" | jq
)
