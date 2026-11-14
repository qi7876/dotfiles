status is-interactive; or return 0

set -g __fish_git_prompt_showdirtystate yes
set -g __fish_git_prompt_showuntrackedfiles yes
set -g __fish_git_prompt_showupstream auto
set -g __fish_git_prompt_showcolorhints yes

alias ls 'ls --color=auto -F'
alias ll 'ls -Alh'
alias g git
alias n nvim
alias s ssh
alias nv 'nvidia-smi --query-gpu=index,name,memory.used,memory.total,utilization.gpu --format=csv,noheader'

fish_default_key_bindings
fzf --fish | source
zoxide init fish | source
