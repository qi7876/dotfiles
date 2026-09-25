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
        set -- shell-macos git tmux kitty vim agents ssh
        ;;
    Linux)
        set -- shell-linux git tmux vim agents ssh
        ;;
    *)
        printf 'error: unsupported platform: %s\n' "$kernel_name" >&2
        exit 1
        ;;
esac

mkdir -p "$target"
git_dir="$target/.config/git"
if [ -L "$target/.config" ] || [ -L "$git_dir" ]; then
    printf 'error: %s must be a real directory\n' "$git_dir" >&2
    exit 1
fi
credentials_file="$git_dir/credentials"
if [ -L "$credentials_file" ] \
    || { [ -e "$credentials_file" ] && [ ! -f "$credentials_file" ]; }; then
    printf 'error: %s is not a regular credential file\n' "$credentials_file" >&2
    exit 1
fi

# Check the complete operation before creating links or local-only files.
if ! preflight_output=$(stow --dir="$repo_dir" --target="$target" --no --restow "$@" 2>&1); then
    printf '%s\n' "$preflight_output" >&2
    exit 1
fi

umask 077
mkdir -p "$git_dir" "$target/.local/state/vim" "$target/.ssh"
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
