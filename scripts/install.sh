#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -P "$(dirname "$0")/.." && pwd)
kernel_name=$(uname -s)

set -- \
    "$repo_dir/git/config" "$HOME/.config/git/config" \
    "$repo_dir/nvim/init.lua" "$HOME/.config/nvim/init.lua" \
    "$repo_dir/zed/settings.json" "$HOME/.config/zed/settings.json" \
    "$repo_dir/dprint/dprint.jsonc" "$HOME/.config/dprint/dprint.jsonc" \
    "$repo_dir/starship/starship.toml" "$HOME/.config/starship.toml" \
    "$repo_dir/fish/config.fish" "$HOME/.config/fish/config.fish"
for source in "$repo_dir"/fish/functions/*.fish; do
    set -- "$@" "$source" "$HOME/.config/fish/functions/${source##*/}"
done

if test "$kernel_name" = Darwin; then
    set -- "$@" "$repo_dir/ghostty/config.ghostty" "$HOME/.config/ghostty/config.ghostty"
fi

existing_kind() {
    if test -L "$1"; then
        if test -d "$1"; then
            printf 'directory link'
        elif test -f "$1"; then
            printf 'file link'
        else
            printf 'symbolic link'
        fi
    elif test -d "$1"; then
        printf directory
    elif test -f "$1"; then
        printf file
    else
        printf 'filesystem entry'
    fi
}

report_conflict() {
    printf 'conflict: %s (%s): %s\n' "$1" "$(existing_kind "$1")" "$2" >&2
    conflict_count=$((conflict_count + 1))
}

check_directory() {
    if test -L "$1" || { test -e "$1" && ! test -d "$1"; }; then
        report_conflict "$1" 'expected a real directory'
    fi
}

conflict_count=0
for config_dir in "$HOME/.config" "$HOME/.config/git" "$HOME/.config/nvim" \
    "$HOME/.config/zed" "$HOME/.config/dprint" \
    "$HOME/.config/fish" "$HOME/.config/fish/functions"; do
    check_directory "$config_dir"
done
if test "$kernel_name" = Darwin; then
    check_directory "$HOME/.config/ghostty"
fi
for local_file in "$HOME/.config/git/credentials" "$HOME/.config/fish/secrets.fish"; do
    if test -L "$local_file" || { test -e "$local_file" && ! test -f "$local_file"; }; then
        report_conflict "$local_file" 'expected a regular local file'
    fi
done
for agent_dir in "$HOME/.codex" "$HOME/.dsh"; do
    if test -d "$agent_dir" && ! test -L "$agent_dir"; then
        set -- "$@" "$repo_dir/AGENTS.md" "$agent_dir/AGENTS.md"
    else
        check_directory "$agent_dir"
    fi
done
check_links() {
    while test "$#" -gt 0; do
        source=$1
        destination=$2
        shift 2
        if test -L "$destination"; then
            if test "$(readlink "$destination")" != "$source"; then
                report_conflict "$destination" "expected a link to $source"
            fi
        elif test -e "$destination"; then
            report_conflict "$destination" "expected a link to $source"
        fi
    done
}
check_links "$@"
if test "$conflict_count" -gt 0; then
    printf 'error: %s conflict(s) found\n' "$conflict_count" >&2
    exit 1
fi

umask 077
mkdir -p "$HOME/.config" "$HOME/.config/git" "$HOME/.config/nvim" \
    "$HOME/.config/zed" "$HOME/.config/dprint" \
    "$HOME/.config/fish" "$HOME/.config/fish/functions"
if test "$kernel_name" = Darwin; then
    mkdir -p "$HOME/.config/ghostty"
fi
for local_file in "$HOME/.config/git/credentials" "$HOME/.config/fish/secrets.fish"; do
    if ! test -e "$local_file"; then
        printf '' >"$local_file"
    fi
    chmod 600 "$local_file"
done
while test "$#" -gt 0; do
    source=$1
    destination=$2
    shift 2
    if ! test -L "$destination"; then
        ln -s "$source" "$destination"
    fi
done
