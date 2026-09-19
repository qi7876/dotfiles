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

for file in shell/.zshrc shell/.zprofile shell/.zshenv; do
    zsh -n "$repo_dir/$file" || fail "$file has invalid zsh syntax"
done

grep -q '^Include ~/.ssh/config.local$' "$repo_dir/ssh/.ssh/config" \
    || fail "SSH config does not include the local file"

printf '%s\n' 'repository safety tests passed'
