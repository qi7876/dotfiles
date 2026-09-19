PROMPT='%F{4}%n@%m %F{5}%~%f
%F{2}%(!.#.$)%f '

export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --walker-skip=Library,.Trash,.cache,.npm,.pnpm-store,.cargo/registry,.rustup,.venv,__pycache__,target"

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ll='ls -AlhF'
alias la='ls -AhF'
alias l='ls -ChF'
alias kssh='kitten ssh'

clip() {
    if [[ "$(uname -s)" == Darwin && -z "$SSH_CONNECTION" ]]; then
        pbcopy
    else
        local data
        data="$(base64 | tr -d '\n')"
        printf '\033]52;c;%s\033\\' "$data" > /dev/tty
    fi
}

ccat() {
    cat -- "$@" | tee >(clip)
}

HISTFILE="$HOME/.zsh_history"
HISTSIZE=20000
SAVEHIST=10000

setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

autoload -Uz compinit
compinit

bindkey -e
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"

socks5h() {
    ALL_PROXY="socks5h://127.0.0.1:7890" \
    all_proxy="socks5h://127.0.0.1:7890" \
    "$@"
}

socks5() {
    ALL_PROXY="socks5://127.0.0.1:7890" \
    all_proxy="socks5://127.0.0.1:7890" \
    "$@"
}

_mhcurl() {
    : "${MIHOMO_API:?set MIHOMO_API in ~/.config/dotfiles/secrets.zsh}"
    if [[ -n "${MIHOMO_SECRET:-}" ]]; then
        command curl -fsS -H "Authorization: Bearer $MIHOMO_SECRET" "$@"
    else
        command curl -fsS "$@"
    fi
}

alias mh-ver='_mhcurl "$MIHOMO_API/version" | jq'
alias mh-status='_mhcurl "$MIHOMO_API/proxies" | jq -r '\''
    .proxies
    | to_entries[]
    | select(.value.now != null)
    | "\(.key) -> \(.value.now)"
'\'''

mh-get-group() {
    local name="${1:?usage: mh-get-group <group>}"
    local encoded
    encoded=$(printf '%s' "$name" | jq -sRr @uri)
    _mhcurl "$MIHOMO_API/proxies/$encoded" | jq
}

mh-set-group-proxy() {
    local group="${1:?usage: mh-set-group-proxy <group> <proxy>}"
    local proxy="${2:?usage: mh-set-group-proxy <group> <proxy>}"
    local encoded
    encoded=$(printf '%s' "$group" | jq -sRr @uri)
    _mhcurl -X PUT -H 'Content-Type: application/json' \
        -d "$(jq -cn --arg name "$proxy" '{name: $name}')" \
        "$MIHOMO_API/proxies/$encoded"
    printf '%s -> %s\n' "$group" "$proxy"
}

mh-delay-group() {
    local group="${1:?usage: mh-delay-group <group>}"
    local encoded
    encoded=$(printf '%s' "$group" | jq -sRr @uri)
    _mhcurl "$MIHOMO_API/group/$encoded/delay?url=https%3A%2F%2Fwww.gstatic.com%2Fgenerate_204&timeout=5000" | jq
}

alias mh-close='_mhcurl -X DELETE "$MIHOMO_API/connections"'
alias mh-flush-dns='_mhcurl -X POST "$MIHOMO_API/cache/dns/flush"'

mh-update-provider() {
    local provider="${1:?usage: mh-update-provider <provider>}"
    local encoded
    encoded=$(printf '%s' "$provider" | jq -sRr @uri)
    _mhcurl -X PUT "$MIHOMO_API/providers/proxies/$encoded"
    printf 'Updated: %s\n' "$provider"
}

mh-reload() {
    : "${MIHOMO_CONFIG:?set MIHOMO_CONFIG in ~/.config/dotfiles/secrets.zsh}"
    _mhcurl -X PUT -H 'Content-Type: application/json' \
        -d "$(jq -cn --arg path "$MIHOMO_CONFIG" '{path: $path}')" \
        "$MIHOMO_API/configs?force=true"
    printf '%s\n' 'mihomo config reloaded'
}

mh-restart() {
    _mhcurl -X POST -H 'Content-Type: application/json' -d '{}' "$MIHOMO_API/restart"
}

mh-upgrade() {
    _mhcurl -X POST -H 'Content-Type: application/json' -d '{}' "$MIHOMO_API/upgrade"
}
