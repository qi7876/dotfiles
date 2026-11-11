mh-set-mode() {
        if [ "$#" -ne 1 ]; then
                printf 'usage: mh-set-mode <global|direct|rule>\n' >&2
                return 1
        fi
        case "$1" in
        global | direct | rule) ;;
        *)
                printf 'usage: mh-set-mode <global|direct|rule>\n' >&2
                return 1
                ;;
        esac
        local payload
        payload=$(jq -cn --arg mode "$1" '{mode: $mode}') || return $?
        _mhcurl -X PATCH -H 'Content-Type: application/json' \
                -d "$payload" "$MIHOMO_API/configs" || return $?
        printf 'Mode: %s\n' "$1"
}
