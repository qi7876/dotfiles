PROMPT='%F{4}%n@%m %F{5}%~%f
%F{2}%(!.#.$)%f '

export FZF_DEFAULT_OPTS='--walker-skip=Library,.Trash,.cache,.npm,.pnpm-store,.cargo/registry,.git,node_modules,.venv,venv,__pycache__,.pytest_cache,.mypy_cache,.ruff_cache,.tox,.nox,target,dist,.astro'

alias l='ls -ChF'
alias ll='ls -AlhF'
alias ks='kitten ssh'
alias v='nvim'
alias g='git'
alias c='cargo'

HISTFILE="$HOME/.zsh_history"
HISTSIZE=20000
SAVEHIST=10000
KEYTIMEOUT=5

setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

autoload -Uz compinit
compinit

eval "$(mise activate zsh)"
source <(fzf --zsh)
eval "$(zoxide init zsh)"

copy() {
    setopt local_options pipe_fail

    if (( $# != 1 )); then
        print -u2 "usage: copy <file>"
        return 1
    fi

    local data
    data="$(base64 < "$1" | tr -d '\n')" || return $?

    printf '\033]52;c;%s\033\\' "$data" > /dev/tty
}

_mhcurl() {
    : "${MIHOMO_API:?set MIHOMO_API in ~/.secrets.zsh}"
    if [[ -n "${MIHOMO_SECRET:-}" ]]; then
        command curl -fsS -H "Authorization: Bearer $MIHOMO_SECRET" "$@"
    else
        command curl -fsS "$@"
    fi
}

mh-ver() {
    setopt local_options pipe_fail
    _mhcurl "$MIHOMO_API/version" | jq
}

mh-status() {
    setopt local_options pipe_fail
    _mhcurl "$MIHOMO_API/proxies" | jq -r '
        .proxies
        | to_entries[]
        | select(.value.now != null)
        | "\(.key) -> \(.value.now)"
    '
}

mh-get-group() {
    setopt local_options pipe_fail
    local name="${1:?usage: mh-get-group <group>}"
    local encoded
    encoded=$(printf '%s' "$name" | jq -sRr @uri) || return $?
    _mhcurl "$MIHOMO_API/proxies/$encoded" | jq
}

mh-set-group-proxy() {
    local group="${1:?usage: mh-set-group-proxy <group> <proxy>}"
    local proxy="${2:?usage: mh-set-group-proxy <group> <proxy>}"
    local encoded
    local payload
    encoded=$(printf '%s' "$group" | jq -sRr @uri) || return $?
    payload=$(jq -cn --arg name "$proxy" '{name: $name}') || return $?
    _mhcurl -X PUT -H 'Content-Type: application/json' \
        -d "$payload" \
        "$MIHOMO_API/proxies/$encoded" || return $?
    printf '%s -> %s\n' "$group" "$proxy"
}

mh-delay-group() {
    setopt local_options pipe_fail
    local group="${1:?usage: mh-delay-group <group>}"
    local encoded
    encoded=$(printf '%s' "$group" | jq -sRr @uri) || return $?
    _mhcurl "$MIHOMO_API/group/$encoded/delay?url=https%3A%2F%2Fwww.gstatic.com%2Fgenerate_204&timeout=5000" | jq
}

mh-update-provider() {
    local provider="${1:?usage: mh-update-provider <provider>}"
    local encoded
    encoded=$(printf '%s' "$provider" | jq -sRr @uri) || return $?
    _mhcurl -X PUT "$MIHOMO_API/providers/proxies/$encoded" || return $?
    printf 'Updated: %s\n' "$provider"
}

mh-restart() {
    _mhcurl -X POST -H 'Content-Type: application/json' -d '{}' "$MIHOMO_API/restart"
}

mh-upgrade() {
    _mhcurl -X POST -H 'Content-Type: application/json' -d '{}' "$MIHOMO_API/upgrade"
}
