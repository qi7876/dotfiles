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

remove_link() {
    if [ -L "$2" ] && [ "$(readlink "$2")" = "$1" ]; then
        rm "$2"
    fi
}

managed_links remove_link
for agent_dir in .codex .dsh; do
    remove_link "$repo_dir/AGENTS.md" "$HOME/$agent_dir/AGENTS.md"
done
