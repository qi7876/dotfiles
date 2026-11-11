# Non-login Bash shells inherit the environment from their parent.
[[ $- == *i* ]] || return 0

# Append history so concurrent shells do not overwrite one another.
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend checkwinsize

export FZF_DEFAULT_OPTS='--walker-skip=Library,.Trash,.cache,.npm,.pnpm-store,.cargo/registry,.git,node_modules,.venv,venv,__pycache__,.pytest_cache,.mypy_cache,.ruff_cache,.tox,.nox,target,dist,.astro'

alias ls='ls --color=auto -F'
alias ll='ls -Alh'
alias g=git
alias n=nvim
alias s=ssh
alias nv='nvidia-smi --query-gpu=index,name,memory.used,memory.total,utilization.gpu --format=csv,noheader'

if [[ $(uname -s) == Linux ]]; then
        eval "$(mise activate bash)"
fi
source <(fzf --bash)
eval "$(zoxide init bash)"
eval "$(starship init bash)"
