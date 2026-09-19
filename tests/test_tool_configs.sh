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

vim -Nu "$repo_dir/vim/.config/vim/vimrc" -n -es \
    '+if !empty(v:errmsg) | cquit | endif' '+qa!' \
    || fail "Vim configuration could not be loaded"
SSH_CONNECTION='127.0.0.1 1 127.0.0.1 2' \
    vim -Nu "$repo_dir/vim/.config/vim/vimrc" -n -es \
    '+if !exists("g:osc52_force_avail") || !empty(v:errmsg) | cquit | endif' '+qa!' \
    || fail "Vim SSH configuration could not be loaded"

git config --file "$repo_dir/git/.config/git/config" --list >/dev/null \
    || fail "Git configuration could not be loaded"

if command -v kitty >/dev/null 2>&1; then
    KITTY_CONFIG_PATH="$repo_dir/kitty/.config/kitty/kitty.conf" \
        kitty +runpy 'import os; from kitty.config import load_config; bad = []; load_config(os.environ["KITTY_CONFIG_PATH"], accumulate_bad_lines=bad); assert not bad, bad' \
        || fail "Kitty configuration could not be loaded"
    KITTY_CONFIG_DIRECTORY="$repo_dir/kitty/.config/kitty" \
        kitten ssh -G example.com >/dev/null 2>&1 \
        || fail "Kitty SSH configuration could not be loaded"
fi

if command -v gh >/dev/null 2>&1; then
    GH_CONFIG_DIR="$repo_dir/gh/.config/gh" gh config list >/dev/null \
        || fail "GitHub CLI configuration could not be loaded"
fi

printf '%s\n' 'tool configuration tests passed'
