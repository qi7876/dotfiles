status is-interactive; or return 0

abbr l 'ls --color=auto -F'
abbr ll 'ls -Alh'
abbr g git
abbr v nvim
abbr nv 'nvidia-smi --query-gpu=index,name,memory.used,memory.total,utilization.gpu --format=csv,noheader'

fish_default_key_bindings
fzf --fish | source
zoxide init fish | source
