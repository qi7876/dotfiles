#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
target=${DOTFILES_TARGET:-$HOME}
. "$repo_dir/scripts/managed-links.sh"

if [ "$#" -ne 0 ]; then
    printf 'usage: %s\n' "$0" >&2
    exit 2
fi

kernel_name=$(uname -s)
case "$kernel_name" in
    Darwin | Linux) ;;
    *)
        printf 'error: unsupported platform: %s\n' "$kernel_name" >&2
        exit 1
        ;;
esac

remove_link() {
    if [ -L "$2" ] && [ "$(readlink "$2")" = "$1" ]; then
        rm "$2"
    fi
}

managed_links remove_link
for agent_dir in .codex .dsh .claude; do
    remove_link "$repo_dir/AGENTS.md" "$target/$agent_dir/AGENTS.md"
done
