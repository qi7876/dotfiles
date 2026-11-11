function mh-update-provider
    if not set -q argv[1]; or test -z "$argv[1]"
        printf 'usage: mh-update-provider <provider>\n' >&2
        return 1
    end
    set -l encoded (printf '%s' "$argv[1]" | jq -sRr @uri)
    or return $status
    _mhcurl -X PUT "$MIHOMO_API/providers/proxies/$encoded"
    or return $status
    printf 'Updated: %s\n' "$argv[1]"
end
