# refactor/platform-zsh-configs

## Intent

Replace runtime platform branching in Zsh with two independently maintained
macOS and Linux configurations. Keep platform selection in the Stow management
scripts so the user-facing package name remains `shell`.

## Progress

- Added complete `shell-macos` and `shell-linux` package trees.
- Added install-time Darwin/Linux resolution and unsupported-platform errors.
- Added integration coverage for both platforms, idempotency, and safe failure.
- Migrated the active macOS links from the former `shell` package.

## Completion criteria

- Neither Zsh package contains runtime OS detection or shared fragments.
- Both platform configurations pass syntax and install tests.
- Active macOS links resolve to `shell-macos`.
- Documentation describes the logical `shell` interface and platform behavior.
