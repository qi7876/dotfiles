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
    Darwin) shell_package=shell-macos ;;
    Linux) shell_package=shell-linux ;;
    *)
        printf 'error: unsupported platform: %s\n' "$kernel_name" >&2
        exit 1
        ;;
esac

set -- "$shell_package" git tmux kitty vim gh agents ssh

mkdir -p "$target"

# Check the complete operation before creating links or local-only files.
if ! preflight_output=$(stow --dir="$repo_dir" --target="$target" --no --restow "$@" 2>&1); then
    printf '%s\n' "$preflight_output" >&2
    exit 1
fi

umask 077
mkdir -p "$target/.config/dotfiles" "$target/.local/state/vim" "$target/.ssh"
secrets_file="$target/.config/dotfiles/secrets.zsh"
ssh_local_file="$target/.ssh/config.local"

if [ ! -e "$secrets_file" ]; then
    cp "$repo_dir/templates/secrets.zsh.example" "$secrets_file"
fi
if [ ! -e "$ssh_local_file" ]; then
    cp "$repo_dir/templates/ssh-config.local.example" "$ssh_local_file"
fi
chmod 600 "$secrets_file" "$ssh_local_file"

stow --dir="$repo_dir" --target="$target" --restow "$@"
