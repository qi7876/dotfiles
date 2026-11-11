if ((BASH_VERSINFO[0] < 5)); then
        printf 'This configuration requires Bash 5 or newer.\n' >&2
        return 1
fi

shell_kernel=$(uname -s)
shell_paths=("$HOME/.local/bin" "$HOME/.cargo/bin")
if [[ $shell_kernel == Darwin ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv bash)"
        shell_paths+=(/opt/homebrew/opt/node@26/bin /opt/homebrew/opt/rustup/bin)
fi

# Move configured directories to the front and remove duplicate PATH entries.
shell_path_list=()
declare -A shell_seen_paths=()
for shell_path in "${shell_paths[@]}"; do
        [[ -d $shell_path ]] && shell_path_list+=("$shell_path")
done
mapfile -d : -t shell_paths < <(printf '%s:' "$PATH")
shell_paths=("${shell_path_list[@]}" "${shell_paths[@]}")
shell_path_list=()
for shell_path in "${shell_paths[@]}"; do
        # The suffix permits empty PATH entries (the current directory) as keys.
        [[ -v 'shell_seen_paths[$shell_path/]' ]] && continue
        shell_seen_paths["$shell_path/"]=1
        shell_path_list+=("$shell_path")
done
printf -v PATH '%s:' "${shell_path_list[@]}"
export PATH=${PATH%:}
unset shell_paths shell_path_list shell_seen_paths shell_path

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
if [[ -f "$HOME/.config/bash/secrets.bash" ]]; then
        source "$HOME/.config/bash/secrets.bash"
fi

for shell_function in "$HOME"/.config/bash/functions/*.bash; do
        [[ -f "$shell_function" ]] && source "$shell_function"
done
unset shell_function

if [[ $- != *i* ]]; then
        unset shell_kernel
        return 0
fi

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

if [[ $shell_kernel == Linux ]]; then
        eval "$(mise activate bash)"
fi
unset shell_kernel
source <(fzf --bash)
eval "$(zoxide init bash)"
eval "$(starship init bash)"
