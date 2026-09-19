#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
missing=''

for command_name in git stow zsh fzf zoxide jq tmux vim rg ssh; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        missing="$missing $command_name"
    fi
done

if [ -n "$missing" ]; then
    printf 'error: missing required commands:%s\n' "$missing" >&2
    exit 1
fi

"$repo_dir/tests/run.sh"
printf '%s\n' 'all checks passed'
