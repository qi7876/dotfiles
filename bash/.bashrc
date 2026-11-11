# Non-login Bash shells inherit the environment from their parent.
[[ $- == *i* ]] || return 0

exec fish
