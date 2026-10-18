function copy
    if test (count $argv) -ne 1
        printf 'usage: copy <file>\n' >&2
        return 1
    end

    set -l data (base64 < "$argv[1]")
    or return $status
    set data (string join '' -- $data)
    printf '\033]52;c;%s\033\\' "$data" >/dev/tty
end
