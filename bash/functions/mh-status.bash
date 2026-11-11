mh-status() (
        set -o pipefail
        _mhcurl "$MIHOMO_API/proxies" | jq -r '
        .proxies
        | to_entries[]
        | select(.value.now != null)
        | "\(.key) -> \(.value.now)"
    '
)
