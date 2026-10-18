set -l shell_paths "$HOME/.local/bin" "$HOME/.cargo/bin"
switch (uname -s)
    case Darwin
        /opt/homebrew/bin/brew shellenv fish | source
        or return $status
        set -a shell_paths /opt/homebrew/opt/node@24/bin /opt/homebrew/opt/rustup/bin
end
for entry in $PATH
    if not contains -- "$entry" $shell_paths
        set -a shell_paths "$entry"
    end
end
set -gx PATH $shell_paths

set -gx VISUAL nvim
set -gx EDITOR nvim
set -gx SUDO_EDITOR nvim
set -gx UV_DEFAULT_INDEX https://mirrors.aliyun.com/pypi/simple/
set -gx http_proxy http://127.0.0.1:7890
set -gx https_proxy "$http_proxy"
set -gx HTTP_PROXY "$http_proxy"
set -gx HTTPS_PROXY "$https_proxy"
set -gx no_proxy localhost,127.0.0.1,::1
set -gx NO_PROXY "$no_proxy"
set -gx MIHOMO_API http://127.0.0.1:9090

if test -f "$__fish_config_dir/secrets.fish"
    source "$__fish_config_dir/secrets.fish"
    or return $status
end

if status is-interactive
    set -gx FZF_DEFAULT_OPTS '--walker-skip=Library,.Trash,.cache,.npm,.pnpm-store,.cargo/registry,.git,node_modules,.venv,venv,__pycache__,.pytest_cache,.mypy_cache,.ruff_cache,.tox,.nox,target,dist,.astro'

    alias l 'ls -ChF'
    alias ll 'ls -AlhF'
    alias g git
    alias n nvim
    alias s 'kitten ssh'

    fish_default_key_bindings
    if test (uname -s) = Linux
        mise activate fish | source
    end
    fzf --fish | source
    zoxide init fish | source
    starship init fish | source
end
