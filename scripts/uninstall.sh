#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
target=${DOTFILES_TARGET:-$HOME}

if [ "$#" -ne 0 ]; then
    printf 'usage: %s\n' "$0" >&2
    exit 2
fi

command -v stow >/dev/null 2>&1 || {
    printf '%s\n' 'error: GNU Stow is required' >&2
    exit 1
}

kernel_name=$(uname -s)
case "$kernel_name" in
    Darwin) set -- shell-macos kitty ssh ;;
    Linux) set -- shell-linux ssh ;;
    *)
        printf 'error: unsupported platform: %s\n' "$kernel_name" >&2
        exit 1
        ;;
esac

stow --dir="$repo_dir" --target="$target" --delete "$@"
for config_file in .gitconfig .vimrc .tmux.conf; do
    link="$target/$config_file"
    if [ -L "$link" ] && [ "$(readlink "$link")" = "$repo_dir/$config_file" ]; then
        rm "$link"
    fi
done
for agent_dir in .codex .dsh .claude; do
    link="$target/$agent_dir/AGENTS.md"
    if [ -L "$link" ] && [ "$(readlink "$link")" = "$repo_dir/AGENTS.md" ]; then
        rm "$link"
    fi
done
