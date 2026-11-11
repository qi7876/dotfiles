function mh-get-group
    if not set -q argv[1]; or test -z "$argv[1]"
        printf 'usage: mh-get-group <group>\n' >&2
        return 1
    end
    set -l encoded (printf '%s' "$argv[1]" | jq -sRr @uri)
    or return $status
    _mhcurl "$MIHOMO_API/proxies/$encoded" | jq
    set -l results $pipestatus
    for result in $results[-1..1]
        if test $result -ne 0
            return $result
        end
    end
    return 0
end
