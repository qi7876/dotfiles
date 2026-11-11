# Environment and secrets are inherited from the Bash login shell.
status is-interactive; or return 0

alias ls 'ls --color=auto -F'
alias ll 'ls -Alh'
alias g git
alias n nvim
alias s ssh
alias nv 'nvidia-smi --query-gpu=index,name,memory.used,memory.total,utilization.gpu --format=csv,noheader'

fish_default_key_bindings
if test (uname -s) = Linux
    mise activate fish | source
end
fzf --fish | source
zoxide init fish | source
starship init fish | source
