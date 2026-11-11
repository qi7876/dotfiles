if [[ $(uname -s) == Darwin ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv bash)"
        export PATH="/opt/homebrew/opt/node@26/bin:/opt/homebrew/opt/rustup/bin:$PATH"
fi
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

if [[ $(uname -s) == Linux ]]; then
        eval "$(mise activate bash --shims)"
fi

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
export FZF_DEFAULT_OPTS='--walker-skip=Library,.Trash,.cache,.npm,.pnpm-store,.cargo/registry,.git,node_modules,.venv,venv,__pycache__,.pytest_cache,.mypy_cache,.ruff_cache,.tox,.nox,target,dist,.astro'
source "$HOME/.secrets"

# Interactive login shells also load Bash functions and integrations.
if [[ $- == *i* ]]; then
        source "$HOME/.bashrc"
fi
