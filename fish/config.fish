set -l kernel_name (uname -s)
set -l shell_paths \
    "$HOME/.local/bin" \
    "$HOME/.cargo/bin"
if test "$kernel_name" = Darwin
    /opt/homebrew/bin/brew shellenv fish | source
    set -a shell_paths \
        /opt/homebrew/opt/node@24/bin \
        /opt/homebrew/opt/rustup/bin
end
fish_add_path --path --move $shell_paths

set -gx VISUAL nvim
set -gx EDITOR nvim
set -gx SUDO_EDITOR nvim
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8
set -gx UV_DEFAULT_INDEX https://mirrors.aliyun.com/pypi/simple/
set -gx http_proxy http://127.0.0.1:7890
set -gx https_proxy "$http_proxy"
set -gx HTTP_PROXY "$http_proxy"
set -gx HTTPS_PROXY "$https_proxy"
set -gx no_proxy localhost,127.0.0.1,::1
set -gx NO_PROXY "$no_proxy"
set -gx MIHOMO_API http://127.0.0.1:9090
source "$__fish_config_dir/secrets.fish"

status is-interactive; or return 0

set -gx FZF_DEFAULT_OPTS '--walker-skip=Library,.Trash,.cache,.npm,.pnpm-store,.cargo/registry,.git,node_modules,.venv,venv,__pycache__,.pytest_cache,.mypy_cache,.ruff_cache,.tox,.nox,target,dist,.astro'

alias l 'ls -ChF'
alias ll 'ls -AlhF'
alias g git
alias n nvim
alias s ssh

fish_default_key_bindings
if test "$kernel_name" = Linux
    mise activate fish | source
end
fzf --fish | source
zoxide init fish | source
starship init fish | source
