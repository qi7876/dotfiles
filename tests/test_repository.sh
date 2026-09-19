#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

git -C "$repo_dir" ls-files --cached --others --exclude-standard \
    | grep -Eq '(^|/)(hosts\.yml|id_[^/]+|known_hosts|\.zsh_history|viminfo|\.netrwhist|.*\.bak)$' \
    && fail "a private or runtime file is tracked"

if rg -n --glob '!tests/**' --glob '!.git/**' \
    'MIHOMO_SECRET=[^[:space:]#]+|Password:[[:space:]]*[^[:space:]]+' "$repo_dir"; then
    fail "a likely plaintext secret is tracked"
fi

for platform in macos linux; do
    for file in .zshrc .zprofile .zshenv; do
        zsh -n "$repo_dir/shell-$platform/$file" \
            || fail "shell-$platform/$file has invalid zsh syntax"
    done
done

for file in scripts/install.sh scripts/uninstall.sh scripts/check.sh; do
    sh -n "$repo_dir/$file" || fail "$file has invalid POSIX shell syntax"
done

if rg -n 'uname|Darwin|Linux' "$repo_dir/shell-macos" "$repo_dir/shell-linux"; then
    fail "runtime platform detection exists inside a Zsh configuration"
fi

grep -q 'pbcopy' "$repo_dir/shell-macos/.zshrc" \
    || fail "macOS clipboard configuration is missing"
grep -Fq "printf '\\033]52" "$repo_dir/shell-linux/.zshrc" \
    || fail "Linux OSC52 clipboard configuration is missing"
if rg -n '/opt/homebrew|pbcopy' "$repo_dir/shell-linux"; then
    fail "Linux configuration contains a macOS-only setting"
fi

grep -q '^Include ~/.ssh/config.local$' "$repo_dir/ssh/.ssh/config" \
    || fail "SSH config does not include the local file"

printf '%s\n' 'repository safety tests passed'
