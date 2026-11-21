#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -P "$(dirname "$0")/.." && pwd)

set -- \
        "$repo_dir/fish/config.fish" "$HOME/.config/fish/config.fish" \
        "$repo_dir/git/config" "$HOME/.gitconfig" \
        "$repo_dir/nvim/init.lua" "$HOME/.config/nvim/init.lua" \
        "$repo_dir/bash/.bash_profile" "$HOME/.bash_profile"

for agent_dir in "$HOME/.codex" "$HOME/.gemini" "$HOME/.claude"; do
        set -- "$@" "$repo_dir/AGENTS.md" "$agent_dir/AGENTS.md"
done
while test "$#" -gt 0; do
        source=$1
        destination=$2
        shift 2
        if test -L "$destination" && test "$(readlink "$destination")" = "$source"; then
                rm "$destination"
        fi
done
