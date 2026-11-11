# Non-login Bash shells inherit the environment from their parent.
[[ $- == *i* ]] || return 0

# Append history so concurrent shells do not overwrite one another.
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend checkwinsize

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
eval "$(starship init bash)"
eval "$(zoxide init bash)"
