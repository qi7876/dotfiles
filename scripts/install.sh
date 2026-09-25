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
    Darwin)
        set -- shell-macos kitty ssh
        ;;
    Linux)
        set -- shell-linux ssh
        ;;
    *)
        printf 'error: unsupported platform: %s\n' "$kernel_name" >&2
        exit 1
        ;;
esac

mkdir -p "$target"
credentials_file="$target/.git-credentials"
if [ -L "$credentials_file" ] \
    || { [ -e "$credentials_file" ] && [ ! -f "$credentials_file" ]; }; then
    printf 'error: %s is not a regular credential file\n' "$credentials_file" >&2
    exit 1
fi
for config_file in .gitconfig .vimrc .tmux.conf; do
    link="$target/$config_file"
    if [ -L "$link" ]; then
        if [ "$(readlink "$link")" != "$repo_dir/$config_file" ]; then
            printf 'error: %s is not managed by this repository\n' "$link" >&2
            exit 1
        fi
    elif [ -e "$link" ]; then
        printf 'error: %s already exists\n' "$link" >&2
        exit 1
    fi
done
for agent_dir in .codex .dsh .claude; do
    directory="$target/$agent_dir"
    if [ -d "$directory" ]; then
        link="$directory/AGENTS.md"
        if [ -L "$link" ]; then
            if [ "$(readlink "$link")" != "$repo_dir/AGENTS.md" ]; then
                printf 'error: %s is not managed by this repository\n' "$link" >&2
                exit 1
            fi
        elif [ -e "$link" ]; then
            printf 'error: %s already exists\n' "$link" >&2
            exit 1
        fi
    elif [ -e "$directory" ] || [ -L "$directory" ]; then
        printf 'error: %s is not a directory\n' "$directory" >&2
        exit 1
    fi
done

# Check the complete operation before creating links or local-only files.
if ! preflight_output=$(stow --dir="$repo_dir" --target="$target" --no --restow "$@" 2>&1); then
    printf '%s\n' "$preflight_output" >&2
    exit 1
fi

umask 077
mkdir -p "$target/.local/state/vim" "$target/.ssh"
if [ ! -e "$credentials_file" ]; then
    : >"$credentials_file"
fi
secrets_file="$target/.secrets.zsh"
ssh_local_file="$target/.ssh/config.local"

if [ ! -e "$secrets_file" ]; then
    cp "$repo_dir/templates/secrets.zsh.example" "$secrets_file"
fi
if [ ! -e "$ssh_local_file" ]; then
    cp "$repo_dir/templates/ssh-config.local.example" "$ssh_local_file"
fi
chmod 600 "$credentials_file" "$secrets_file" "$ssh_local_file"
stow --dir="$repo_dir" --target="$target" --restow "$@"
for config_file in .gitconfig .vimrc .tmux.conf; do
    link="$target/$config_file"
    if [ ! -L "$link" ]; then
        ln -s "$repo_dir/$config_file" "$link"
    fi
done
for agent_dir in .codex .dsh .claude; do
    directory="$target/$agent_dir"
    if [ -d "$directory" ] && [ ! -L "$directory/AGENTS.md" ]; then
        ln -s "$repo_dir/AGENTS.md" "$directory/AGENTS.md"
    fi
done
