typeset -U path PATH
path=(
    "$HOME/.local/bin"
    "/opt/homebrew/opt/node@24/bin"
    "$HOME/.cargo/bin"
    "/opt/homebrew/opt/rustup/bin"
    $path
)

export VISUAL='vim'
export EDITOR='vim'
export SUDO_EDITOR='vim'
export UV_DEFAULT_INDEX='https://mirrors.aliyun.com/pypi/simple/'

source "$HOME/.config/dotfiles/secrets.zsh"
