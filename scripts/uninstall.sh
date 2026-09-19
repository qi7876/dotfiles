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

stow --dir="$repo_dir" --target="$target" --delete "$@"
