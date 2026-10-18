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

set -l config_dirs "$HOME/.config" "$HOME/.config/git" "$HOME/.config/nvim" \
    "$HOME/.config/fish" "$HOME/.config/fish/functions"
if test "$kernel_name" = Darwin
    set -a config_dirs "$HOME/.config/kitty"
end
set -l local_files "$HOME/.config/git/credentials" "$HOME/.config/fish/secrets.fish"

function existing_kind
    if test -L "$argv[1]"
        if test -d "$argv[1]"
            printf 'directory link'
        else if test -f "$argv[1]"
            printf 'file link'
        else
            printf 'symbolic link'
        end
    else if test -d "$argv[1]"
        printf directory
    else if test -f "$argv[1]"
        printf file
    else
        printf 'filesystem entry'
    end
end

function report_conflict
    printf 'conflict: %s (%s): %s\n' "$argv[1]" (existing_kind "$argv[1]") "$argv[2]" >&2
    set -g conflict_count (math $conflict_count + 1)
end

function check_directory
    if test -L "$argv[1]"; or begin
            test -e "$argv[1]"; and not test -d "$argv[1]"
        end
        report_conflict "$argv[1]" 'expected a real directory'
    end
end

set -g conflict_count 0
for config_dir in $config_dirs
    check_directory "$config_dir"
end
for local_file in $local_files
    if test -L "$local_file"; or begin
            test -e "$local_file"; and not test -f "$local_file"
        end
        report_conflict "$local_file" 'expected a regular local file'
    end
end
for agent_dir in "$HOME/.codex" "$HOME/.dsh"
    if test -d "$agent_dir"; and not test -L "$agent_dir"
        set -a links "$repo_dir/AGENTS.md" "$agent_dir/AGENTS.md"
    else
        check_directory "$agent_dir"
    end
end
for index in (seq 1 2 (count $links))
    set -l source $links[$index]
    set -l destination $links[(math $index + 1)]
    if test -L "$destination"
        if test (readlink "$destination") != "$source"
            report_conflict "$destination" "expected a link to $source"
        end
    else if test -e "$destination"
        report_conflict "$destination" "expected a link to $source"
    end
end
if test $conflict_count -gt 0
    printf 'error: %s conflict(s) found\n' $conflict_count >&2
    exit 1
end

umask 077
mkdir -p $config_dirs
or exit $status
for local_file in $local_files
    if not test -e "$local_file"
        printf '' >"$local_file"
        or exit $status
    end
    chmod 600 "$local_file"
    or exit $status
end
for index in (seq 1 2 (count $links))
    set -l source $links[$index]
    set -l destination $links[(math $index + 1)]
    if not test -L "$destination"
        ln -s "$source" "$destination"
        or exit $status
    end
end
