#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
target=${DOTFILES_TARGET:-$HOME}
all_packages='shell git tmux kitty vim gh agents ssh'

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

resolved_packages=''
for package in "$@"; do
    if [ "$package" = shell ]; then
        resolved_package=$shell_package
    else
        resolved_package=$package
    fi
    resolved_packages="$resolved_packages $resolved_package"
done
set -- $resolved_packages

stow --dir="$repo_dir" --target="$target" --delete "$@"
