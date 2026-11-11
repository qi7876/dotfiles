mh-set-group-proxy() {
        if [[ -z ${1:-} || -z ${2:-} ]]; then
                printf 'usage: mh-set-group-proxy <group> <proxy>\n' >&2
                return 1
        fi
        local encoded payload
        encoded=$(printf '%s' "$1" | jq -sRr @uri) || return $?
        payload=$(jq -cn --arg name "$2" '{name: $name}') || return $?
        _mhcurl -X PUT -H 'Content-Type: application/json' \
                -d "$payload" "$MIHOMO_API/proxies/$encoded" || return $?
        printf '%s -> %s\n' "$1" "$2"
}
