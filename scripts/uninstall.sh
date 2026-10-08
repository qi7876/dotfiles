#!/usr/bin/env zsh
set -eu

repo_dir=${0:A:h:h}
kernel_name=$(uname -s)

links=(
    "$repo_dir/jj/config.toml" "$HOME/.config/jj/config.toml"
    "$repo_dir/git/config" "$HOME/.config/git/config"
    "$repo_dir/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
    "$repo_dir/nvim/init.lua" "$HOME/.config/nvim/init.lua"
    "$repo_dir/ssh/config" "$HOME/.ssh/config"
)

case $kernel_name in
    Darwin)
        for config_file in .z{shrc,profile,shenv}; do
            links+=("$repo_dir/shell-macos/$config_file" "$HOME/$config_file")
        done
        for config_file in kitty.conf ssh.conf current-theme.conf; do
            links+=("$repo_dir/kitty/$config_file" "$HOME/.config/kitty/$config_file")
        done
        ;;
    Linux)
        for config_file in .z{shrc,profile,shenv}; do
            links+=("$repo_dir/shell-linux/$config_file" "$HOME/$config_file")
        done
        ;;
esac

for agent_dir in "$HOME"/{.codex,.dsh}; do
    links+=("$repo_dir/AGENTS.md" "$agent_dir/AGENTS.md")
done

for source destination in "${links[@]}"; do
    if [[ -L $destination && $(readlink "$destination") == $source ]]; then
        rm "$destination"
    fi
done
