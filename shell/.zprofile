if (( $+commands[brew] )); then
    eval "$(brew shellenv)"
fi

if [[ "$(uname -s)" == Darwin ]]; then
    [[ -d /opt/homebrew/opt/rustup/bin ]] && path=(/opt/homebrew/opt/rustup/bin $path)
    [[ -d /opt/homebrew/opt/node@24/bin ]] && path=(/opt/homebrew/opt/node@24/bin $path)
fi
