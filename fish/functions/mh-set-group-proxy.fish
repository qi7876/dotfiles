function mh-set-group-proxy
    if not set -q argv[2]; or test -z "$argv[1]"; or test -z "$argv[2]"
        printf 'usage: mh-set-group-proxy <group> <proxy>\n' >&2
        return 1
    end
    set -l encoded (printf '%s' "$argv[1]" | jq -sRr @uri)
    or return $status
    set -l payload (jq -cn --arg name "$argv[2]" '{name: $name}')
    or return $status
    _mhcurl -X PUT -H 'Content-Type: application/json' \
        -d "$payload" "$MIHOMO_API/proxies/$encoded"
    or return $status
    printf '%s -> %s\n' "$argv[1]" "$argv[2]"
end
