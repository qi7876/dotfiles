#!/usr/bin/env zsh
set -eu

repo_dir=${0:A:h:h}
kernel_name=$(uname -s)

links=(
    "$repo_dir/git/config" "$HOME/.config/git/config"
    "$repo_dir/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
    "$repo_dir/nvim/init.lua" "$HOME/.config/nvim/init.lua"
    "$repo_dir/ssh/config" "$HOME/.ssh/config"
)
config_dirs=("$HOME"/.config{,/git,/tmux,/nvim} "$HOME/.zfunc" "$HOME/.ssh")
local_files=("$HOME/.config/git/credentials" "$HOME/.secrets.zsh" "$HOME/.ssh/config.local")

case $kernel_name in
    Darwin)
        for config_file in .z{shrc,profile,shenv}; do
            links+=("$repo_dir/shell-macos/$config_file" "$HOME/$config_file")
        done
        for config_file in kitty.conf ssh.conf current-theme.conf; do
            links+=("$repo_dir/kitty/$config_file" "$HOME/.config/kitty/$config_file")
        done
        config_dirs+=("$HOME/.config/kitty")
        ;;
    Linux)
        for config_file in .z{shrc,profile,shenv}; do
            links+=("$repo_dir/shell-linux/$config_file" "$HOME/$config_file")
        done
        ;;
esac

existing_kind() {
    if [[ -L $1 ]]; then
        if [[ -d $1 ]]; then
            print -n 'directory link'
        elif [[ -f $1 ]]; then
            print -n 'file link'
        else
            print -n 'symbolic link'
        fi
    elif [[ -d $1 ]]; then
        print -n 'directory'
    elif [[ -f $1 ]]; then
        print -n 'file'
    else
        print -n 'filesystem entry'
    fi
}

report_conflict() {
    print -ru2 -- "conflict: $1 ($(existing_kind "$1")): $2"
    (( conflict_count += 1 ))
}

check_directory() {
    if [[ -L $1 || ( -e $1 && ! -d $1 ) ]]; then
        report_conflict "$1" 'expected a real directory'
    fi
}

conflict_count=0
for config_dir in "${config_dirs[@]}"; do
    check_directory "$config_dir"
done

for local_file in "${local_files[@]}"; do
    if [[ -L $local_file || ( -e $local_file && ! -f $local_file ) ]]; then
        report_conflict "$local_file" 'expected a regular local file'
    fi
done

for agent_dir in "$HOME"/{.codex,.dsh}; do
    if [[ -d $agent_dir && ! -L $agent_dir ]]; then
        links+=("$repo_dir/AGENTS.md" "$agent_dir/AGENTS.md")
    else
        check_directory "$agent_dir"
    fi
done

for source destination in "${links[@]}"; do
    if [[ -L $destination ]]; then
        if [[ $(readlink "$destination") != $source ]]; then
            report_conflict "$destination" "expected a link to $source"
        fi
    elif [[ -e $destination ]]; then
        report_conflict "$destination" "expected a link to $source"
    fi
done

if (( conflict_count > 0 )); then
    print -ru2 -- "error: $conflict_count conflict(s) found"
    exit 1
fi

umask 077
mkdir -p "${config_dirs[@]}"

for local_file in "${local_files[@]}"; do
    if [[ ! -e $local_file ]]; then
        : >"$local_file"
    fi
    chmod 600 "$local_file"
done

for source destination in "${links[@]}"; do
    if [[ ! -L $destination ]]; then
        ln -s "$source" "$destination"
    fi
done
