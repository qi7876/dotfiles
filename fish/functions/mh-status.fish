function mh-status
    _mhcurl "$MIHOMO_API/proxies" | jq -r '
        .proxies
        | to_entries[]
        | select(.value.now != null)
        | "\(.key) -> \(.value.now)"
    '
    set -l results $pipestatus
    for result in $results[-1..1]
        if test $result -ne 0
            return $result
        end
    end
    return 0
end
