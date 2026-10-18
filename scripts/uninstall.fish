#!/usr/bin/env -S XDG_CONFIG_HOME=/dev/null XDG_DATA_HOME=/dev/null XDG_CACHE_HOME=/dev/null fish --no-config

# Isolate fish startup: even --no-config can create a default config and caches.
# Managed files always use the explicit ~/.config paths below.
set -l repo_dir (path resolve (status dirname)/..)
or exit $status
set -l kernel_name (uname -s)
or exit $status

set -l links \
    "$repo_dir/git/config" "$HOME/.config/git/config" \
    "$repo_dir/nvim/init.lua" "$HOME/.config/nvim/init.lua" \
    "$repo_dir/starship/starship.toml" "$HOME/.config/starship.toml" \
    "$repo_dir/fish/config.fish" "$HOME/.config/fish/config.fish"
for source in "$repo_dir"/fish/functions/*.fish
    set -a links "$source" "$HOME/.config/fish/functions/"(path basename "$source")
end

if test "$kernel_name" = Darwin
    for config_file in kitty.conf ssh.conf
        set -a links "$repo_dir/kitty/$config_file" "$HOME/.config/kitty/$config_file"
    end
end

for agent_dir in "$HOME/.codex" "$HOME/.dsh"
    set -a links "$repo_dir/AGENTS.md" "$agent_dir/AGENTS.md"
end
for index in (seq 1 2 (count $links))
    set -l source $links[$index]
    set -l destination $links[(math $index + 1)]
    if test -L "$destination"; and test (readlink "$destination") = "$source"
        rm "$destination"
        or exit $status
    end
end
