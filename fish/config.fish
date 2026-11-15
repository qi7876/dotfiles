status is-interactive; or return 0

abbr l 'ls --color=auto -F'
abbr ll 'ls -Alh'
abbr g 'git'
abbr gst 'git status --short --branch'
abbr glg 'git log --graph --decorate --oneline --all --max-count 20'
abbr gd 'git diff --color-moved --color-moved-ws=allow-indentation-change'
abbr gdc 'git diff --cached --color-moved --color-moved-ws=allow-indentation-change'
abbr gds 'git diff --stat --compact-summary'
abbr v nvim
abbr nv 'nvidia-smi --query-gpu=index,name,memory.used,memory.total,utilization.gpu --format=csv,noheader'

fish_default_key_bindings
fzf --fish | source
zoxide init fish | source
