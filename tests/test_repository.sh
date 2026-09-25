#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

test ! -e "$repo_dir/gh" || fail "GitHub CLI configuration remains in the repository"

git -C "$repo_dir" ls-files --cached --others --exclude-standard \
    | grep -Eq '(^|/)(credentials|secrets\.zsh|hosts\.yml|id_[^/]+|known_hosts|\.zsh_history|viminfo|\.netrwhist|.*\.bak)$' \
    && fail "a private or runtime file is tracked"

if rg -n 'gh auth git-credential|^\[credential "https://(github|gist)\.com"\]' \
    "$repo_dir/git/.config/git/config"; then
    fail "Git configuration still uses a GitHub CLI credential helper"
fi

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

for command_name in rg ssh; do
    grep -Eq "^for command_name in .* ${command_name}([[:space:]]|;)" \
        "$repo_dir/scripts/check.sh" \
        || fail "check.sh does not declare $command_name as a test dependency"
done

if rg -n 'uname|Darwin|Linux' "$repo_dir/shell-macos" "$repo_dir/shell-linux"; then
    fail "runtime platform detection exists inside a Zsh configuration"
fi

grep -Fq "printf '\\033]52" "$repo_dir/shell-macos/.zshrc" \
    || fail "macOS OSC52 clipboard configuration is missing"
if rg -n 'pbcopy|SSH_CONNECTION' "$repo_dir/shell-macos/.zshrc"; then
    fail "macOS clipboard configuration still has platform-specific branches"
fi
grep -Fq "printf '\\033]52" "$repo_dir/shell-linux/.zshrc" \
    || fail "Linux OSC52 clipboard configuration is missing"
if rg -n '/opt/homebrew|pbcopy' "$repo_dir/shell-linux"; then
    fail "Linux configuration contains a macOS-only setting"
fi

expected_fzf_opts='--walker-skip=Library,.Trash,.cache,.npm,.pnpm-store,.cargo/registry,.git,node_modules,.venv,venv,__pycache__,.pytest_cache,.mypy_cache,.ruff_cache,.tox,.nox,target,dist,.astro'
for platform in macos linux; do
    actual_fzf_opts=$(FZF_DEFAULT_OPTS='--layout=reverse' zsh -c '
        source "$1" 2>/dev/null
        source "$1" 2>/dev/null
        printf "%s" "$FZF_DEFAULT_OPTS"
    ' zsh "$repo_dir/shell-$platform/.zshrc")
    test "$actual_fzf_opts" = "$expected_fzf_opts" \
        || fail "shell-$platform does not set idempotent FZF defaults"
    grep -Fq 'source <(fzf --zsh)' "$repo_dir/shell-$platform/.zshrc" \
        || fail "shell-$platform does not use native FZF sourcing"
    if grep -Fq 'eval "$(fzf --zsh)"' "$repo_dir/shell-$platform/.zshrc"; then
        fail "shell-$platform still evals FZF integration"
    fi
    if grep -Eq '^alias mh-(ver|status)=' "$repo_dir/shell-$platform/.zshrc"; then
        fail "shell-$platform still defines complex Mihomo aliases"
    fi
done

for platform in macos linux; do
    grep -Fq 'typeset -U path PATH' "$repo_dir/shell-$platform/.zshenv" \
        || fail "shell-$platform does not use the unique Zsh path array"
    grep -Fq 'path=(' "$repo_dir/shell-$platform/.zshenv" \
        || fail "shell-$platform does not initialize the Zsh path array"
done
grep -Fq '"/opt/homebrew/opt/node@24/bin"' "$repo_dir/shell-macos/.zshenv" \
    || fail "macOS Node path is not initialized from .zshenv"
grep -Fq 'eval "$(/opt/homebrew/bin/brew shellenv)"' "$repo_dir/shell-macos/.zprofile" \
    || fail "macOS Homebrew initialization is not using the fixed path"
if rg -n 'node@24' "$repo_dir/shell-macos/.zprofile"; then
    fail "non-login PATH initialization remains in .zprofile"
fi

grep -q '^Include ~/.ssh/config.local$' "$repo_dir/ssh/.ssh/config" \
    || fail "SSH config does not include the local file"

printf '%s\n' 'repository safety tests passed'
