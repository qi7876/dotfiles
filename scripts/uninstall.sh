#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -P "$(dirname "$0")/.." && pwd)
kernel_name=$(uname -s)

set -- \
        "$repo_dir/git/config" "$HOME/.config/git/config" \
        "$repo_dir/nvim/init.lua" "$HOME/.config/nvim/init.lua" \
        "$repo_dir/dprint/dprint.jsonc" "$HOME/.config/dprint/dprint.jsonc" \
        "$repo_dir/starship/starship.toml" "$HOME/.config/starship.toml" \
        "$repo_dir/fish/config.fish" "$HOME/.config/fish/config.fish"
for source in "$repo_dir"/fish/functions/*.fish; do
        set -- "$@" "$source" "$HOME/.config/fish/functions/${source##*/}"
done

for agent_dir in "$HOME/.codex" "$HOME/.dsh" "$HOME/.claude"; do
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
