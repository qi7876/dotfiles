# Non-login Bash shells inherit the environment from their parent.
[[ $- == *i* ]] || return 0

if command -v fish >/dev/null 2>&1; then
        exec fish
else
        printf 'fish is not installed; continuing in Bash\n' >&2
fi
