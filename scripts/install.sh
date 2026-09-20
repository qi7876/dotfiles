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
        obsolete_package=
        ;;
    Linux)
        set -- shell-linux git tmux vim agents ssh
        obsolete_package=kitty
        ;;
    *)
        printf 'error: unsupported platform: %s\n' "$kernel_name" >&2
        exit 1
        ;;
esac

mkdir -p "$target"

# Check the complete operation before creating links or local-only files.
if ! preflight_output=$(stow --dir="$repo_dir" --target="$target" --no --restow "$@" 2>&1); then
    printf '%s\n' "$preflight_output" >&2
    exit 1
fi
if [ -n "$obsolete_package" ] \
    && ! cleanup_output=$(stow --dir="$repo_dir" --target="$target" --no --delete "$obsolete_package" 2>&1); then
    printf '%s\n' "$cleanup_output" >&2
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

if [ -n "$obsolete_package" ]; then
    stow --dir="$repo_dir" --target="$target" --delete "$obsolete_package"
fi
stow --dir="$repo_dir" --target="$target" --restow "$@"
