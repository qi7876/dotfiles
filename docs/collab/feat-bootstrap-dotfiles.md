# feat/bootstrap-dotfiles

## Intent

Import the current shell and development-tool configuration into a portable GNU
Stow repository while separating all credentials and machine-specific SSH data.

## Progress

- Added package layout for shell, Git, tmux, Kitty, Vim, gh, Agents, and SSH.
- Added conflict-safe install, uninstall, dependency check, and local tests.
- Split local secrets and private SSH hosts into files outside the repository.
- Migrated the active macOS configuration with a recoverable backup.
- Completed all acceptance checks and prepared the branch for local merge.

## Completion criteria

- All local tests pass.
- A fresh temporary home can be installed twice and uninstalled safely.
- Active configuration resolves to this repository.
- No credential or runtime file is tracked.
