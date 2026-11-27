if [[ $(uname -s) == 'Darwin' ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv bash)"
        export PATH="/opt/homebrew/opt/rustup/bin:/opt/homebrew/opt/llvm/bin:$PATH"
        export LDFLAGS='-L/opt/homebrew/opt/llvm/lib'
        export CPPFLAGS='-I/opt/homebrew/opt/llvm/include'
else
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
        export PATH="/home/linuxbrew/.linuxbrew/opt/rustup/bin:$PATH"
fi
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

export EDITOR='nvim'
export VISUAL="$EDITOR"
export SUDO_EDITOR="$EDITOR"
export UV_DEFAULT_INDEX='https://mirrors.aliyun.com/pypi/simple/'
export http_proxy='http://127.0.0.1:7890'
export HTTP_PROXY="$http_proxy"
export https_proxy="$http_proxy"
export HTTPS_PROXY="$http_proxy"
export no_proxy='localhost,127.0.0.1,::1,.local'
export NO_PROXY="$no_proxy"
export MIHOMO_API='http://127.0.0.1:9090'
export FZF_DEFAULT_OPTS='--walker-skip=Library,.Trash,.cache,.npm,.pnpm-store,.cargo/registry,.git,node_modules,.venv,venv,__pycache__,.pytest_cache,.mypy_cache,.ruff_cache,.tox,.nox,target,dist,.astro'
alias f='fish'
source "$HOME/.secrets.sh"
