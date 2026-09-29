typeset -U path PATH
path=(
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "/opt/homebrew/opt/node@24/bin"
    "/opt/homebrew/opt/rustup/bin"
    $path
)

export VISUAL='nvim'
export EDITOR='nvim'
export SUDO_EDITOR='nvim'

export UV_DEFAULT_INDEX='https://mirrors.aliyun.com/pypi/simple/'

export http_proxy='http://127.0.0.1:7890'
export https_proxy="$http_proxy"
export HTTP_PROXY="$http_proxy"
export HTTPS_PROXY="$https_proxy"

export no_proxy='localhost,127.0.0.1,::1'
export NO_PROXY="$no_proxy"

export MIHOMO_API='http://127.0.0.1:9090'

source "$HOME/.secrets.zsh"
