if [ "$(uname -s)" = Darwin ]; then
        eval "$(/opt/homebrew/bin/brew shellenv bash)"
fi

# Prepend existing directories once, preserving the configured order.
for shell_path in /opt/homebrew/opt/rustup/bin /opt/homebrew/opt/node@26/bin "$HOME/.cargo/bin" "$HOME/.local/bin"; do
        case "$shell_path" in
        /opt/homebrew/*) [ "$(uname -s)" = Darwin ] || continue ;;
        esac
        [ -d "$shell_path" ] || continue
        case ":$PATH:" in
        *":$shell_path:"*) ;;
        *) PATH="$shell_path:$PATH" ;;
        esac
done
unset shell_path
export PATH

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
if [ -f "$HOME/.config/bash/secrets.bash" ]; then
        source "$HOME/.config/bash/secrets.bash"
fi

for shell_function in "$HOME"/.config/bash/functions/*.bash; do
        [ -f "$shell_function" ] && source "$shell_function"
done
unset shell_function

case $- in
*i*) ;;
*) return 0 ;;
esac

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

if [ "$(uname -s)" = Linux ]; then
        eval "$(mise activate bash)"
fi
source <(fzf --bash)
eval "$(zoxide init bash)"
eval "$(starship init bash)"
