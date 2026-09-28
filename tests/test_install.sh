#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test_root=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-test.XXXXXX")
trap 'rm -rf "$test_root"' EXIT HUP INT TERM

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

assert_link() {
    test -L "$1" || fail "$1 is not a symbolic link"
}

fake_uname() {
    fake_dir=$1
    kernel_name=$2
    mkdir -p "$fake_dir"
    printf '%s\n' '#!/bin/sh' "printf '%s\\n' '$kernel_name'" >"$fake_dir/uname"
    chmod +x "$fake_dir/uname"
}

home_dir="$test_root/home"
mkdir -p "$home_dir/.codex" "$home_dir/.claude" \
    "$home_dir/.config/nvim" "$home_dir/.config/kitty"
printf '%s\n' 'local configuration' >"$home_dir/.config/nvim/local.lua"
printf '%s\n' 'local theme' >"$home_dir/.config/kitty/local.conf"
darwin_bin="$test_root/darwin-bin"
fake_uname "$darwin_bin" Darwin

PATH="$darwin_bin:$PATH" DOTFILES_TARGET="$home_dir" "$repo_dir/scripts/install.sh"

assert_link "$home_dir/.zshrc"
assert_link "$home_dir/.zprofile"
assert_link "$home_dir/.zshenv"
case "$(realpath "$home_dir/.zshrc")" in
    "$repo_dir/shell-macos/"*) ;;
    *) fail "Darwin did not select shell-macos" ;;
esac
assert_link "$home_dir/.config/git/config"
test "$(readlink "$home_dir/.config/git/config")" = "$repo_dir/git/.config/git/config" \
    || fail "Git configuration does not link to the repository"
assert_link "$home_dir/.config/tmux/tmux.conf"
test "$(readlink "$home_dir/.config/tmux/tmux.conf")" = "$repo_dir/tmux/.config/tmux/tmux.conf" \
    || fail "tmux configuration does not link to the repository"
assert_link "$home_dir/.config/nvim/init.lua"
test "$(readlink "$home_dir/.config/nvim/init.lua")" = "$repo_dir/nvim/.config/nvim/init.lua" \
    || fail "Neovim init.lua does not link directly to the repository"
test -d "$home_dir/.config/nvim" && test ! -L "$home_dir/.config/nvim" \
    || fail "Neovim directory was replaced by a link"
test "$(cat "$home_dir/.config/nvim/local.lua")" = 'local configuration' \
    || fail "local Neovim configuration was modified"
for config_file in kitty.conf ssh.conf current-theme.conf; do
    assert_link "$home_dir/.config/kitty/$config_file"
    test "$(readlink "$home_dir/.config/kitty/$config_file")" = \
        "$repo_dir/kitty/.config/kitty/$config_file" \
        || fail "Kitty $config_file does not link to the repository"
done
test -d "$home_dir/.config/kitty" && test ! -L "$home_dir/.config/kitty" \
    || fail "Kitty directory was replaced by a link"
test "$(cat "$home_dir/.config/kitty/local.conf")" = 'local theme' \
    || fail "local Kitty configuration was modified"
for config_dir in git tmux nvim kitty; do
    test -d "$home_dir/.config/$config_dir" && test ! -L "$home_dir/.config/$config_dir" \
        || fail "$config_dir directory is not a real directory"
done
test -d "$home_dir/.ssh" && test ! -L "$home_dir/.ssh" \
    || fail "SSH directory is not a real directory"
test "$(HOME="$home_dir" XDG_CONFIG_HOME="$home_dir/.config" \
    git config --global --get user.name)" = qi7876 \
    || fail "Git did not load the XDG configuration"
tmux_label="dotfiles-install-test-$$"
HOME="$home_dir" XDG_CONFIG_HOME="$home_dir/.config" \
    tmux -L "$tmux_label" new-session -d \
    || fail "tmux did not load the XDG configuration"
test "$(tmux -L "$tmux_label" show-options -gqv default-terminal)" = tmux-256color \
    || fail "tmux did not apply the XDG configuration"
tmux -L "$tmux_label" kill-server
for agent_dir in .codex .claude; do
    assert_link "$home_dir/$agent_dir/AGENTS.md"
    test "$(readlink "$home_dir/$agent_dir/AGENTS.md")" = "$repo_dir/AGENTS.md" \
        || fail "$agent_dir/AGENTS.md does not link directly to the repository root"
done
test ! -e "$home_dir/.dsh" || fail "install created an absent agent directory"
test ! -e "$home_dir/.config/agents" || fail "install deployed the old AGENTS path"
test ! -e "$home_dir/.config/gh" \
    || fail "Darwin install deployed GitHub CLI configuration"
assert_link "$home_dir/.ssh/config"

credentials_file="$home_dir/.git-credentials"
secrets_file="$home_dir/.secrets.zsh"
ssh_local_file="$home_dir/.ssh/config.local"
test -f "$credentials_file" || fail "Git credentials file was not created"
test ! -s "$credentials_file" || fail "Git credentials file is not empty by default"
test -f "$secrets_file" || fail "secrets file was not created"
test -f "$ssh_local_file" || fail "SSH local config was not created"
test ! -e "$home_dir/.local/state/vim" || fail "legacy Vim state directory was created"
test "$(stat -f '%Lp' "$secrets_file" 2>/dev/null || stat -c '%a' "$secrets_file")" = 600 \
    || fail "secrets file permissions are not 600"
test "$(stat -f '%Lp' "$credentials_file" 2>/dev/null || stat -c '%a' "$credentials_file")" = 600 \
    || fail "Git credentials file permissions are not 600"

printf '%s\n' 'export TEST_SECRET=preserved' >"$secrets_file"
printf '%s\n' 'https://test-user:test-token@example.com' >"$credentials_file"
printf '%s\n' 'Host private-example' >"$ssh_local_file"
PATH="$darwin_bin:$PATH" DOTFILES_TARGET="$home_dir" "$repo_dir/scripts/install.sh"
grep -q 'TEST_SECRET=preserved' "$secrets_file" || fail "secrets file was overwritten"
test "$(cat "$credentials_file")" = 'https://test-user:test-token@example.com' \
    || fail "Git credentials file was overwritten"
grep -q 'Host private-example' "$ssh_local_file" || fail "SSH local config was overwritten"

PATH="$darwin_bin:$PATH" DOTFILES_TARGET="$home_dir" "$repo_dir/scripts/uninstall.sh"
test ! -L "$home_dir/.zshrc" || fail "shell link was not removed"
test ! -L "$home_dir/.ssh/config" || fail "SSH config link was not removed"
test ! -e "$home_dir/.config/git/config" || fail "uninstall retained Git config"
test ! -e "$home_dir/.config/tmux/tmux.conf" || fail "uninstall retained tmux config"
test ! -e "$home_dir/.config/nvim/init.lua" || fail "uninstall retained Neovim init.lua"
test -d "$home_dir/.config/nvim" || fail "uninstall removed Neovim directory"
test "$(cat "$home_dir/.config/nvim/local.lua")" = 'local configuration' \
    || fail "uninstall changed local Neovim configuration"
for config_file in kitty.conf ssh.conf current-theme.conf; do
    test ! -e "$home_dir/.config/kitty/$config_file" \
        || fail "uninstall retained Kitty $config_file"
done
test -d "$home_dir/.config/kitty" || fail "uninstall removed Kitty directory"
test "$(cat "$home_dir/.config/kitty/local.conf")" = 'local theme' \
    || fail "uninstall changed local Kitty configuration"
for agent_dir in .codex .claude; do
    test ! -e "$home_dir/$agent_dir/AGENTS.md" \
        || fail "uninstall retained $agent_dir/AGENTS.md"
    test -d "$home_dir/$agent_dir" || fail "uninstall removed $agent_dir"
done
test -f "$secrets_file" || fail "uninstall removed the secrets file"
test -f "$credentials_file" || fail "uninstall removed the Git credentials file"
test -f "$ssh_local_file" || fail "uninstall removed the SSH local config"
test ! -e "$home_dir/.local/state/vim" || fail "uninstall created Vim state"

conflict_home="$test_root/conflict-home"
mkdir -p "$conflict_home"
printf '%s\n' 'keep me' >"$conflict_home/.zshrc"
if conflict_output=$(PATH="$darwin_bin:$PATH" DOTFILES_TARGET="$conflict_home" \
    "$repo_dir/scripts/install.sh" 2>&1); then
    fail "install succeeded despite an existing file conflict"
fi
printf '%s\n' "$conflict_output" | grep -q '.zshrc' \
    || fail "install hid the Stow conflict diagnostic"
test "$(cat "$conflict_home/.zshrc")" = 'keep me' || fail "conflicting file was modified"

agent_conflict_home="$test_root/agent-conflict-home"
mkdir -p "$agent_conflict_home/.codex"
printf '%s\n' 'keep me' >"$agent_conflict_home/.codex/AGENTS.md"
if PATH="$darwin_bin:$PATH" DOTFILES_TARGET="$agent_conflict_home" \
    "$repo_dir/scripts/install.sh" >/dev/null 2>&1; then
    fail "install replaced an existing AGENTS.md"
fi
test ! -e "$agent_conflict_home/.config/git/config" \
    || fail "agent conflict caused a partial install"
test "$(cat "$agent_conflict_home/.codex/AGENTS.md")" = 'keep me' \
    || fail "existing AGENTS.md was changed"

nvim_conflict_home="$test_root/nvim-conflict-home"
mkdir -p "$nvim_conflict_home/.config/nvim"
printf '%s\n' 'keep me' >"$nvim_conflict_home/.config/nvim/init.lua"
if PATH="$darwin_bin:$PATH" DOTFILES_TARGET="$nvim_conflict_home" \
    "$repo_dir/scripts/install.sh" >/dev/null 2>&1; then
    fail "install replaced an existing Neovim configuration"
fi
test ! -e "$nvim_conflict_home/.config/git/config" \
    || fail "Neovim conflict caused a partial install"
test "$(cat "$nvim_conflict_home/.config/nvim/init.lua")" = 'keep me' \
    || fail "existing Neovim configuration was changed"

kitty_conflict_home="$test_root/kitty-conflict-home"
mkdir -p "$kitty_conflict_home/.config"
ln -s "$repo_dir/kitty/.config/kitty" "$kitty_conflict_home/.config/kitty"
if PATH="$darwin_bin:$PATH" DOTFILES_TARGET="$kitty_conflict_home" \
    "$repo_dir/scripts/install.sh" >/dev/null 2>&1; then
    fail "install accepted a linked Kitty directory"
fi
test ! -e "$kitty_conflict_home/.config/git/config" \
    || fail "Kitty directory conflict caused a partial install"
test -L "$kitty_conflict_home/.config/kitty" \
    || fail "conflicting Kitty directory link was modified"

linux_home="$test_root/linux-home"
linux_bin="$test_root/linux-bin"
mkdir -p "$linux_home/.config" "$linux_home/.dsh"
fake_uname "$linux_bin" Linux
PATH="$linux_bin:$PATH" DOTFILES_TARGET="$linux_home" "$repo_dir/scripts/install.sh"
assert_link "$linux_home/.config/nvim/init.lua"
assert_link "$linux_home/.config/git/config"
assert_link "$linux_home/.config/tmux/tmux.conf"
test -d "$linux_home/.config/nvim" && test ! -L "$linux_home/.config/nvim" \
    || fail "Linux Neovim directory was linked instead of created"
case "$(realpath "$linux_home/.zshrc")" in
    "$repo_dir/shell-linux/"*) ;;
    *) fail "Linux did not select shell-linux" ;;
esac
test ! -e "$linux_home/.config/kitty" \
    || fail "Linux install deployed the Kitty configuration"
test "$(readlink "$linux_home/.dsh/AGENTS.md")" = "$repo_dir/AGENTS.md" \
    || fail "Linux did not link AGENTS.md into an existing .dsh directory"
PATH="$linux_bin:$PATH" DOTFILES_TARGET="$linux_home" "$repo_dir/scripts/install.sh"

unsupported_home="$test_root/unsupported-home"
unsupported_bin="$test_root/unsupported-bin"
mkdir -p "$unsupported_home"
fake_uname "$unsupported_bin" FreeBSD
if PATH="$unsupported_bin:$PATH" DOTFILES_TARGET="$unsupported_home" \
    "$repo_dir/scripts/install.sh" >/dev/null 2>&1; then
    fail "unsupported platform was accepted"
fi
test ! -e "$unsupported_home/.zshrc" || fail "unsupported platform created a shell link"
test ! -e "$unsupported_home/.secrets.zsh" \
    || fail "unsupported platform created a local secrets file"

argument_home="$test_root/argument-home"
mkdir -p "$argument_home"
if PATH="$darwin_bin:$PATH" DOTFILES_TARGET="$argument_home" \
    "$repo_dir/scripts/install.sh" git >/dev/null 2>&1; then
    fail "install accepted a package argument"
fi
test ! -e "$argument_home/.secrets.zsh" \
    || fail "argument rejection happened after local file creation"
if PATH="$darwin_bin:$PATH" DOTFILES_TARGET="$argument_home" \
    "$repo_dir/scripts/uninstall.sh" git >/dev/null 2>&1; then
    fail "uninstall accepted a package argument"
fi

printf '%s\n' 'install integration tests passed'
