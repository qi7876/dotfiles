typeset -U path PATH
path=(
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    $path
)

export VISUAL='vim'
export EDITOR='vim'
export SUDO_EDITOR='vim'
export UV_DEFAULT_INDEX='https://mirrors.aliyun.com/pypi/simple/'

source "$HOME/.config/dotfiles/secrets.zsh"
