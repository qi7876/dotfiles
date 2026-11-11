# Environment and secrets are inherited from the Bash login shell.
status is-interactive; or return 0

set -gx FZF_DEFAULT_OPTS '--walker-skip=Library,.Trash,.cache,.npm,.pnpm-store,.cargo/registry,.git,node_modules,.venv,venv,__pycache__,.pytest_cache,.mypy_cache,.ruff_cache,.tox,.nox,target,dist,.astro'

alias ls 'ls --color=auto -ChF'
alias ll 'ls -AlhF'
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
