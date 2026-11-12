status is-interactive; or return 0

alias ls 'ls --color=auto -F'
alias ll 'ls -Alh'
alias g git
alias n nvim
alias s ssh
alias nv 'nvidia-smi --query-gpu=index,name,memory.used,memory.total,utilization.gpu --format=csv,noheader'

fish_default_key_bindings
fzf --fish | source
zoxide init fish | source
starship init fish | source
