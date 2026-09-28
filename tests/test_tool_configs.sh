#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmux_label="dotfiles-test-$$"

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

cleanup() {
    tmux -L "$tmux_label" kill-server >/dev/null 2>&1 || true
}
trap cleanup EXIT HUP INT TERM

tmux -L "$tmux_label" -f "$repo_dir/tmux/.config/tmux/tmux.conf" \
    new-session -d || fail "tmux configuration could not be loaded"
test "$(tmux -L "$tmux_label" show-options -gqv default-terminal)" = tmux-256color \
    || fail "tmux default terminal is incorrect"
cleanup
trap - EXIT HUP INT TERM

nvim --headless -u "$repo_dir/nvim/.config/nvim/init.lua" -i NONE -n \
    '+lua assert(vim.o.scrolloff == 8 and vim.o.tabstop == 4 and vim.o.clipboard == "unnamedplus")' '+qa!' \
    || fail "Neovim configuration could not be loaded"
SSH_CONNECTION='127.0.0.1 1 127.0.0.1 2' \
    nvim --headless -u "$repo_dir/nvim/.config/nvim/init.lua" -i NONE -n \
    '+lua assert(vim.g.clipboard == "osc52")' '+qa!' \
    || fail "Neovim SSH configuration could not be loaded"

git config --file "$repo_dir/git/.config/git/config" --list >/dev/null \
    || fail "Git configuration could not be loaded"
test "$(git config --file "$repo_dir/git/.config/git/config" --get credential.helper)" = store \
    || fail "Git credential helper is incorrect"

if command -v kitty >/dev/null 2>&1; then
    KITTY_CONFIG_PATH="$repo_dir/kitty/.config/kitty/kitty.conf" \
        kitty +runpy 'import os; from kitty.config import load_config; bad = []; load_config(os.environ["KITTY_CONFIG_PATH"], accumulate_bad_lines=bad); assert not bad, bad' \
        || fail "Kitty configuration could not be loaded"
    KITTY_CONFIG_DIRECTORY="$repo_dir/kitty/.config/kitty" \
        kitten ssh -G example.com >/dev/null 2>&1 \
        || fail "Kitty SSH configuration could not be loaded"
fi

printf '%s\n' 'tool configuration tests passed'
