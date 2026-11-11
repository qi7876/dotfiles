function mh-set-mode
    if test (count $argv) -ne 1; or not contains -- "$argv[1]" global direct rule
        printf 'usage: mh-set-mode <global|direct|rule>\n' >&2
        return 1
    end
    set -l payload (jq -cn --arg mode "$argv[1]" '{mode: $mode}')
    or return $status
    _mhcurl -X PATCH -H 'Content-Type: application/json' \
        -d "$payload" "$MIHOMO_API/configs"
    or return $status
    printf 'Mode: %s\n' "$argv[1]"
end
