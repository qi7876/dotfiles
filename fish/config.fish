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

function _mhcurl
    if not set -q MIHOMO_API[1]; or test -z "$MIHOMO_API"
        printf 'set MIHOMO_API in ~/.secrets.sh\n' >&2
        return 1
    end
    command curl -fsS $argv
end

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

function mh-reload
    _mhcurl -X PUT -H 'Content-Type: application/json' -d '{}' "$MIHOMO_API/configs?force=true"
end

function mh-restart
    _mhcurl -X POST -H 'Content-Type: application/json' -d '{}' "$MIHOMO_API/restart"
end

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

function mh-upgrade
    _mhcurl -X POST -H 'Content-Type: application/json' -d '{}' "$MIHOMO_API/upgrade"
end

status is-interactive; or return 0

abbr l 'ls --color=auto -F'
abbr ll 'ls -Alh'
abbr g 'git'
abbr gst 'git status --short --branch'
abbr glg 'git log --graph --decorate --oneline --all --max-count 20'
abbr gd 'git diff --color-moved --color-moved-ws=allow-indentation-change'
abbr gdc 'git diff --cached --color-moved --color-moved-ws=allow-indentation-change'
abbr gds 'git diff --stat --compact-summary'
abbr v nvim
abbr nv 'nvidia-smi --query-gpu=index,name,memory.used,memory.total,utilization.gpu --format=csv,noheader'

fish_default_key_bindings
fzf --fish | source
zoxide init fish | source
