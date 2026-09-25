# refactor/home-config-layout

## Intent

Place the shared Git, Vim, tmux, and AGENTS configurations at the repository
root, then link them directly into the home directory and existing agent tool
directories.

## Progress

- Root configuration files and direct-link handling are in place.
- Moved the current home's Git credentials without changing their contents.
- Local checks pass with the new links.

## Next

- Review the final diff, then squash the branch into main.
