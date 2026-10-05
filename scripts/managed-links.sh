#!/bin/sh

managed_links() {
    link_action=$1

    "$link_action" "$repo_dir/jj/config.toml" "$target/.config/jj/config.toml"
    "$link_action" "$repo_dir/git/config" "$target/.config/git/config"
    "$link_action" "$repo_dir/tmux/tmux.conf" "$target/.config/tmux/tmux.conf"
    "$link_action" "$repo_dir/nvim/init.lua" "$target/.config/nvim/init.lua"
    "$link_action" "$repo_dir/ssh/config" "$target/.ssh/config"

    case "$kernel_name" in
        Darwin)
            for config_file in .zshrc .zprofile .zshenv; do
                "$link_action" "$repo_dir/shell-macos/$config_file" "$target/$config_file"
            done
            for config_file in kitty.conf ssh.conf current-theme.conf; do
                "$link_action" "$repo_dir/kitty/$config_file" \
                    "$target/.config/kitty/$config_file"
            done
            ;;
        Linux)
            for config_file in .zshrc .zprofile .zshenv; do
                "$link_action" "$repo_dir/shell-linux/$config_file" "$target/$config_file"
            done
            ;;
    esac
}
