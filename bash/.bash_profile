# Login shells load the same configuration as interactive non-login shells.
if [[ -f "$HOME/.bashrc" ]]; then
        source "$HOME/.bashrc"
fi
