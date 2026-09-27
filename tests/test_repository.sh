#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

git -C "$repo_dir" ls-files --cached --others --exclude-standard \
    | grep -Eq '(^|/)(credentials|secrets\.zsh|hosts\.yml|id_[^/]+|known_hosts|\.zsh_history|viminfo|\.netrwhist|.*\.bak)$' \
    && fail "a private or runtime file is tracked"

if (cd "$repo_dir" && rg -n --glob '!tests/**' --glob '!.git/**' \
    'MIHOMO_SECRET=[^[:space:]#]+|Password:[[:space:]]*[^[:space:]]+' .); then
    fail "a likely plaintext secret is tracked"
fi

for platform in macos linux; do
    for file in .zshrc .zprofile .zshenv; do
        zsh -n "$repo_dir/shell-$platform/$file" \
            || fail "shell-$platform/$file has invalid zsh syntax"
    done
done

for file in "$repo_dir"/scripts/*.sh "$repo_dir"/tests/*.sh; do
    sh -n "$file" || fail "$file has invalid POSIX shell syntax"
done

printf '%s\n' 'repository safety tests passed'
