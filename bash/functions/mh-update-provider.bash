mh-update-provider() {
        if [ -z "${1:-}" ]; then
                printf 'usage: mh-update-provider <provider>\n' >&2
                return 1
        fi
        local encoded
        encoded=$(printf '%s' "$1" | jq -sRr @uri) || return $?
        _mhcurl -X PUT "$MIHOMO_API/providers/proxies/$encoded" || return $?
        printf 'Updated: %s\n' "$1"
}
