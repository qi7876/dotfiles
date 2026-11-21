# Older installs linked each Fish function separately.
if ! test -L "$HOME/.config" && ! test -L "$HOME/.config/fish" && ! test -L "$HOME/.config/fish/functions"; then
        for link in "$HOME"/.config/fish/functions/*.fish; do
                if test -L "$link" && test "$(readlink "$link")" = "$repo_dir/fish/functions/${link##*/}"; then
                        rm "$link"
                fi
        done
fi
