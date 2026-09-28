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

check_directory() {
    if [ -L "$1" ] || { [ -e "$1" ] && [ ! -d "$1" ]; }; then
        printf 'error: %s is not a regular directory\n' "$1" >&2
        exit 1
    fi
}

check_link() {
    if [ -L "$2" ]; then
        if [ "$(readlink "$2")" != "$1" ]; then
            printf 'error: %s is not managed by this repository\n' "$2" >&2
            exit 1
        fi
    elif [ -e "$2" ]; then
        printf 'error: %s already exists\n' "$2" >&2
        exit 1
    fi
}

create_link() {
    if [ ! -L "$2" ]; then
        ln -s "$1" "$2"
    fi
}

mkdir -p "$target"
credentials_file="$target/.config/git/credentials"
secrets_file="$target/.secrets.zsh"
ssh_local_file="$target/.ssh/config.local"
for local_file in "$credentials_file" "$secrets_file" "$ssh_local_file"; do
    if [ -L "$local_file" ] \
        || { [ -e "$local_file" ] && [ ! -f "$local_file" ]; }; then
        printf 'error: %s is not a regular file\n' "$local_file" >&2
        exit 1
    fi
done

for config_dir in "$target/.config" "$target/.config/git" \
    "$target/.config/tmux" "$target/.config/nvim" "$target/.ssh"; do
    check_directory "$config_dir"
done
if [ "$kernel_name" = Darwin ]; then
    check_directory "$target/.config/kitty"
fi
managed_links check_link

for agent_dir in .codex .dsh .claude; do
    directory="$target/$agent_dir"
    if [ -d "$directory" ] && [ ! -L "$directory" ]; then
        check_link "$repo_dir/AGENTS.md" "$directory/AGENTS.md"
    elif [ -e "$directory" ] || [ -L "$directory" ]; then
        printf 'error: %s is not a regular directory\n' "$directory" >&2
        exit 1
    fi
done

umask 077
mkdir -p "$target/.config/git" "$target/.config/tmux" \
    "$target/.config/nvim" "$target/.ssh"
if [ "$kernel_name" = Darwin ]; then
    mkdir -p "$target/.config/kitty"
fi
for local_file in "$credentials_file" "$secrets_file" "$ssh_local_file"; do
    if [ ! -e "$local_file" ]; then
        : >"$local_file"
    fi
    chmod 600 "$local_file"
done
managed_links create_link
for agent_dir in .codex .dsh .claude; do
    directory="$target/$agent_dir"
    if [ -d "$directory" ] && [ ! -L "$directory/AGENTS.md" ]; then
        ln -s "$repo_dir/AGENTS.md" "$directory/AGENTS.md"
    fi
done
