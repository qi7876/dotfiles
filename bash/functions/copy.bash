copy() {
        if (($# != 1)); then
                printf 'usage: copy <file>\n' >&2
                return 1
        fi
        local data
        data=$(base64 <"$1") || return $?
        data=${data//$'\n'/}
        printf '\033]52;c;%s\033\\' "$data" >/dev/tty
}
