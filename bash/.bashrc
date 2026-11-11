if ((BASH_VERSINFO[0] < 5)); then
        printf 'This configuration requires Bash 5 or newer.\n' >&2
        return 1
fi

shell_kernel=$(uname -s)
shell_paths=("$HOME/.local/bin" "$HOME/.cargo/bin")
if [[ $shell_kernel == Darwin ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv bash)"
        shell_paths+=(/opt/homebrew/opt/node@26/bin /opt/homebrew/opt/rustup/bin)
fi

# Move configured directories to the front and remove duplicate PATH entries.
shell_path_list=()
declare -A shell_seen_paths=()
for shell_path in "${shell_paths[@]}"; do
        [[ -d $shell_path ]] && shell_path_list+=("$shell_path")
done
mapfile -d : -t shell_paths < <(printf '%s:' "$PATH")
shell_paths=("${shell_path_list[@]}" "${shell_paths[@]}")
shell_path_list=()
for shell_path in "${shell_paths[@]}"; do
        # The suffix permits empty PATH entries (the current directory) as keys.
        [[ -v 'shell_seen_paths[$shell_path/]' ]] && continue
        shell_seen_paths["$shell_path/"]=1
        shell_path_list+=("$shell_path")
done
printf -v PATH '%s:' "${shell_path_list[@]}"
export PATH=${PATH%:}
unset shell_paths shell_path_list shell_seen_paths shell_path

export VISUAL=nvim
export EDITOR=nvim
export SUDO_EDITOR=nvim
export UV_DEFAULT_INDEX=https://mirrors.aliyun.com/pypi/simple/
export http_proxy=http://127.0.0.1:7890
export https_proxy="$http_proxy"
export HTTP_PROXY="$http_proxy"
export HTTPS_PROXY="$https_proxy"
export no_proxy=localhost,127.0.0.1,::1
export NO_PROXY="$no_proxy"
export MIHOMO_API=http://127.0.0.1:9090
if [[ -f "$HOME/.bash_secrets" ]]; then
        source "$HOME/.bash_secrets"
fi

_mhcurl() {
        if [[ -z "${MIHOMO_API:-}" ]]; then
                printf 'set MIHOMO_API in ~/.bash_secrets\n' >&2
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

if [[ $- != *i* ]]; then
        unset shell_kernel
        return 0
fi

# Append history so concurrent shells do not overwrite one another.
HISTFILE="$HOME/.bash_history"
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend checkwinsize
bind 'set editing-mode emacs'

export FZF_DEFAULT_OPTS='--walker-skip=Library,.Trash,.cache,.npm,.pnpm-store,.cargo/registry,.git,node_modules,.venv,venv,__pycache__,.pytest_cache,.mypy_cache,.ruff_cache,.tox,.nox,target,dist,.astro'

alias l='ls -ChF'
alias ll='ls -AlhF'
alias g=git
alias n=nvim
alias s=ssh
alias nv='nvidia-smi --query-gpu=index,name,memory.used,memory.total,utilization.gpu --format=csv,noheader'

if [[ $shell_kernel == Linux ]]; then
        eval "$(mise activate bash)"
fi
unset shell_kernel
source <(fzf --bash)
eval "$(zoxide init bash)"
eval "$(starship init bash)"
