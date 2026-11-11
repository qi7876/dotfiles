# Non-login Bash shells inherit the environment from their parent.
[[ $- == *i* ]] || return 0

_mhcurl() {
        if [[ -z "${MIHOMO_API:-}" ]]; then
                printf 'set MIHOMO_API in ~/.secrets\n' >&2
                return 1
        fi
        if [[ -n "${MIHOMO_SECRET:-}" ]]; then
                command curl -fsS -H "Authorization: Bearer $MIHOMO_SECRET" "$@"
        else
                command curl -fsS "$@"
        fi
}

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

# Keep pipeline failure handling local to this function.
mh-delay-group() (
        set -o pipefail
        if [[ -z "${1:-}" ]]; then
                printf 'usage: mh-delay-group <group>\n' >&2
                return 1
        fi
        encoded=$(printf '%s' "$1" | jq -sRr @uri) || return $?
        _mhcurl "$MIHOMO_API/group/$encoded/delay?url=https%3A%2F%2Fwww.gstatic.com%2Fgenerate_204&timeout=5000" | jq
)

# Keep pipeline failure handling local to this function.
mh-get-group() (
        set -o pipefail
        if [[ -z "${1:-}" ]]; then
                printf 'usage: mh-get-group <group>\n' >&2
                return 1
        fi
        encoded=$(printf '%s' "$1" | jq -sRr @uri) || return $?
        _mhcurl "$MIHOMO_API/proxies/$encoded" | jq
)

mh-restart() {
        _mhcurl -X POST -H 'Content-Type: application/json' -d '{}' "$MIHOMO_API/restart"
}

mh-set-group-proxy() {
        if [[ -z ${1:-} || -z ${2:-} ]]; then
                printf 'usage: mh-set-group-proxy <group> <proxy>\n' >&2
                return 1
        fi
        local encoded payload
        encoded=$(printf '%s' "$1" | jq -sRr @uri) || return $?
        payload=$(jq -cn --arg name "$2" '{name: $name}') || return $?
        _mhcurl -X PUT -H 'Content-Type: application/json' \
                -d "$payload" "$MIHOMO_API/proxies/$encoded" || return $?
        printf '%s -> %s\n' "$1" "$2"
}

mh-set-mode() {
        if (($# != 1)); then
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

mh-status() (
        set -o pipefail
        _mhcurl "$MIHOMO_API/proxies" | jq -r '
        .proxies
        | to_entries[]
        | select(.value.now != null)
        | "\(.key) -> \(.value.now)"
    '
)

mh-update-provider() {
        if [[ -z "${1:-}" ]]; then
                printf 'usage: mh-update-provider <provider>\n' >&2
                return 1
        fi
        local encoded
        encoded=$(printf '%s' "$1" | jq -sRr @uri) || return $?
        _mhcurl -X PUT "$MIHOMO_API/providers/proxies/$encoded" || return $?
        printf 'Updated: %s\n' "$1"
}

mh-upgrade() {
        _mhcurl -X POST -H 'Content-Type: application/json' -d '{}' "$MIHOMO_API/upgrade"
}

# Append history so concurrent shells do not overwrite one another.
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend checkwinsize

export FZF_DEFAULT_OPTS='--walker-skip=Library,.Trash,.cache,.npm,.pnpm-store,.cargo/registry,.git,node_modules,.venv,venv,__pycache__,.pytest_cache,.mypy_cache,.ruff_cache,.tox,.nox,target,dist,.astro'

alias ls='ls --color=auto -ChF'
alias ll='ls -AlhF'
alias g=git
alias n=nvim
alias s=ssh
alias nv='nvidia-smi --query-gpu=index,name,memory.used,memory.total,utilization.gpu --format=csv,noheader'

if [[ $(uname -s) == Linux ]]; then
        eval "$(mise activate bash)"
fi
source <(fzf --bash)
eval "$(zoxide init bash)"
eval "$(starship init bash)"
