# fix/final-config-audit

## Intent

Resolve the remaining behavioral and validation gaps found by the final audit
of the shell, editor, terminal, multiplexer, and installation configuration.

## Progress

- Made OSC 52 clipboard helpers propagate upstream pipeline failures.
- Made fresh installs create Vim's local state directory without managing its contents.
- Declared the `rg` and `ssh` commands used by the local test suite.
- Added automated loading checks for tmux, Vim, Git, Kitty, and GitHub CLI configurations.
- Added regression coverage for installation, uninstallation, and shell failure behavior.

## Completion criteria

- Clipboard helpers never report success after an upstream command fails.
- Vim can persist `viminfo` immediately after a fresh installation.
- Local CI reports missing test dependencies before running the suite.
- Managed tool configurations are loaded by their native applications when available.
