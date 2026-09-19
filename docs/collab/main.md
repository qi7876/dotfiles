# Main branch

## Project

Cross-platform personal configuration managed as GNU Stow packages. Shared
configuration is versioned; credentials, machine-specific SSH hosts, histories,
caches, and application state remain local.

## Status

- Baseline repository initialized on `main`.
- Initial GNU Stow bootstrap is implemented and locally tested.
- macOS and Linux use separate, self-contained Zsh packages selected at install time.
- Both platforms use OSC 52 clipboard writes; macOS keeps PATH initialization available to non-login shells.
- Installation and removal are full-set operations with no package-selection interface.
- Both Zsh configurations manage executable search paths through the unique tied `path` array.
- Both Zsh configurations provide the documented proxy and Mihomo non-secret environment defaults.
- Successful installs keep GNU Stow's simulation preflight quiet while preserving conflict diagnostics.
- FZF uses native Zsh integration and skips dependency, cache, and generated directories.
- Mihomo helpers preserve curl, pipeline, encoding, and JSON construction failures.
- Clipboard helpers preserve pipeline failures, and fresh installs prepare Vim's state directory.
- Local CI loads the tmux, Vim, Git, Kitty, and GitHub CLI configurations it can validate.
- No remote repository or remote CI is configured.

## Next

- Add new tools as independent Stow packages when needed.
- Consider a package manifest only when automated machine provisioning becomes
  a requirement.
