# Keep pipeline failure handling local to this function.
mh-delay-group() (
        set -o pipefail
        if [ -z "${1:-}" ]; then
                printf 'usage: mh-delay-group <group>\n' >&2
                return 1
        fi
        encoded=$(printf '%s' "$1" | jq -sRr @uri) || return $?
        _mhcurl "$MIHOMO_API/group/$encoded/delay?url=https%3A%2F%2Fwww.gstatic.com%2Fgenerate_204&timeout=5000" | jq
)
