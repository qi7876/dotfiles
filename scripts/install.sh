#!/bin/sh
set -eu

repo_dir=${0:A:h:h}

managed_links() {
    link_action=$1

    "$link_action" "$repo_dir/jj/config.toml" "$HOME/.config/jj/config.toml"
    "$link_action" "$repo_dir/git/config" "$HOME/.config/git/config"
    "$link_action" "$repo_dir/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
    "$link_action" "$repo_dir/nvim/init.lua" "$HOME/.config/nvim/init.lua"
    "$link_action" "$repo_dir/ssh/config" "$HOME/.ssh/config"

    case "$kernel_name" in
        Darwin)
            for config_file in .zshrc .zprofile .zshenv; do
                "$link_action" "$repo_dir/shell-macos/$config_file" "$HOME/$config_file"
            done
            for config_file in kitty.conf ssh.conf current-theme.conf; do
                "$link_action" "$repo_dir/kitty/$config_file" \
                    "$HOME/.config/kitty/$config_file"
            done
            ;;
        Linux)
            for config_file in .zshrc .zprofile .zshenv; do
                "$link_action" "$repo_dir/shell-linux/$config_file" "$HOME/$config_file"
            done
            ;;
    esac
}

kernel_name=$(uname -s)

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

check_directory() {
    if [ -L "$1" ] || { [ -e "$1" ] && [ ! -d "$1" ]; }; then
        report_conflict "$1" 'expected a real directory'
    fi
}

check_local_file() {
    if [ -L "$1" ] || { [ -e "$1" ] && [ ! -f "$1" ]; }; then
        report_conflict "$1" 'expected a regular local file'
    fi
}

check_link() {
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
credentials_file="$HOME/.config/git/credentials"
secrets_file="$HOME/.secrets.zsh"
ssh_local_file="$HOME/.ssh/config.local"

for config_dir in "$HOME/.config" "$HOME/.zfunc" "$HOME/.config/jj" "$HOME/.config/git" "$HOME/.config/tmux" "$HOME/.config/nvim" "$HOME/.ssh"; do
    check_directory "$config_dir"
done

if [ "$kernel_name" = Darwin ]; then
    check_directory "$HOME/.config/kitty"
fi

for local_file in "$credentials_file" "$secrets_file" "$ssh_local_file"; do
    check_local_file "$local_file"
done

managed_links check_link

for agent_dir in "$HOME/.codex" "$HOME/.dsh"; do
    if [ -d "$agent_dir" ] && [ ! -L "$agent_dir" ]; then
        check_link "$repo_dir/AGENTS.md" "$agent_dir/AGENTS.md"
    else
        check_directory "$agent_dir"
    fi
done

if [ "$conflict_count" -gt 0 ]; then
    printf 'error: %s conflict(s) found\n' "$conflict_count" >&2
    exit 1
fi

umask 077
mkdir -p "$HOME/.config/jj" "$HOME/.zfunc" "$HOME/.config/git" "$HOME/.config/tmux" "$HOME/.config/nvim" "$HOME/.ssh"

if [ "$kernel_name" = Darwin ]; then
    mkdir -p "$HOME/.config/kitty"
fi

for local_file in "$credentials_file" "$secrets_file" "$ssh_local_file"; do
    if [ ! -e "$local_file" ]; then
        : >"$local_file"
    fi
    chmod 600 "$local_file"
done

managed_links create_link
for agent_dir in "$HOME/.codex" "$HOME/.dsh"; do
    if [ -d "$agent_dir" ] && [ ! -L "$agent_dir/AGENTS.md" ]; then
        ln -s "$repo_dir/AGENTS.md" "$agent_dir/AGENTS.md"
    fi
done
