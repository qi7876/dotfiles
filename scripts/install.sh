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

existing_kind() {
    if [ -L "$1" ]; then
        if [ -d "$1" ]; then
            printf 'directory link'
        elif [ -f "$1" ]; then
            printf 'file link'
        else
            printf 'symbolic link'
        fi
    elif [ -d "$1" ]; then
        printf 'directory'
    elif [ -f "$1" ]; then
        printf 'file'
    else
        printf 'filesystem entry'
    fi
}

report_conflict() {
    printf 'conflict: %s (%s): %s\n' "$1" "$(existing_kind "$1")" "$2" >&2
    conflict_count=$((conflict_count + 1))
}

blocked_parent() {
    ancestor=$(dirname "$1")
    while :; do
        if [ -L "$ancestor" ] || { [ -e "$ancestor" ] && [ ! -d "$ancestor" ]; }; then
            return 0
        fi
        if [ "$ancestor" = "$target" ]; then
            break
        fi
        parent=$(dirname "$ancestor")
        if [ "$parent" = "$ancestor" ]; then
            break
        fi
        ancestor=$parent
    done
    return 1
}

check_directory() {
    if [ "$1" != "$target" ] && blocked_parent "$1"; then
        return 0
    fi
    if [ -L "$1" ] || { [ -e "$1" ] && [ ! -d "$1" ]; }; then
        report_conflict "$1" 'expected a real directory'
    fi
}

check_local_file() {
    if blocked_parent "$1"; then
        return 0
    fi
    if [ -L "$1" ] || { [ -e "$1" ] && [ ! -f "$1" ]; }; then
        report_conflict "$1" 'expected a regular local file'
    fi
}

check_link() {
    if blocked_parent "$2"; then
        return 0
    fi
    if [ -L "$2" ]; then
        if [ "$(readlink "$2")" != "$1" ]; then
            report_conflict "$2" "expected a link to $1"
        fi
    elif [ -e "$2" ]; then
        report_conflict "$2" "expected a link to $1"
    fi
}

create_link() {
    if [ ! -L "$2" ]; then
        ln -s "$1" "$2"
    fi
}

conflict_count=0
credentials_file="$target/.config/git/credentials"
secrets_file="$target/.secrets.zsh"
ssh_local_file="$target/.ssh/config.local"
check_directory "$target"
for config_dir in "$target/.config" "$target/.config/git" \
    "$target/.config/tmux" "$target/.config/nvim" "$target/.ssh"; do
    check_directory "$config_dir"
done
if [ "$kernel_name" = Darwin ]; then
    check_directory "$target/.config/kitty"
fi
for local_file in "$credentials_file" "$secrets_file" "$ssh_local_file"; do
    check_local_file "$local_file"
done
managed_links check_link

for agent_dir in .codex .dsh .claude; do
    directory="$target/$agent_dir"
    if [ -d "$directory" ] && [ ! -L "$directory" ]; then
        check_link "$repo_dir/AGENTS.md" "$directory/AGENTS.md"
    else
        check_directory "$directory"
    fi
done
if [ "$conflict_count" -gt 0 ]; then
    printf 'error: %s conflict(s) found\n' "$conflict_count" >&2
    exit 1
fi

umask 077
mkdir -p "$target"
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
