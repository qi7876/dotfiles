function mh-delay-group
    if not set -q argv[1]; or test -z "$argv[1]"
        printf 'usage: mh-delay-group <group>\n' >&2
        return 1
    end
    set -l encoded (printf '%s' "$argv[1]" | jq -sRr @uri)
    or return $status
    _mhcurl "$MIHOMO_API/group/$encoded/delay?url=https%3A%2F%2Fwww.gstatic.com%2Fgenerate_204&timeout=5000" | jq
    set -l results $pipestatus
    for result in $results[-1..1]
        if test $result -ne 0
            return $result
        end
    end
    return 0
end
