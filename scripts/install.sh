#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
target=${DOTFILES_TARGET:-$HOME}
all_packages='shell git tmux kitty vim gh agents ssh'

command -v stow >/dev/null 2>&1 || {
    printf '%s\n' 'error: GNU Stow is required' >&2
    exit 1
}

if [ "$#" -eq 0 ]; then
    set -- $all_packages
fi

for package in "$@"; do
    case " $all_packages " in
        *" $package "*) ;;
        *)
            printf 'error: unknown package: %s\n' "$package" >&2
            exit 1
            ;;
    esac
done

mkdir -p "$target"

# Check the complete operation before creating links or local-only files.
stow --dir="$repo_dir" --target="$target" --no --restow "$@"

umask 077
mkdir -p "$target/.config/dotfiles" "$target/.ssh"
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
