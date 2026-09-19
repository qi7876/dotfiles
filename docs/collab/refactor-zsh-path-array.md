# refactor/zsh-path-array

## Intent

Use the native Zsh `path` array consistently on macOS and Linux while
preserving each platform's existing path entries and precedence.

## Progress

- Replaced macOS chained `PATH` exports with `typeset -U path PATH`.
- Formatted both platform path arrays consistently.
- Added behavioral tests for order, automatic deduplication, and repeated sourcing.

## Completion criteria

- Both `.zshenv` files use the unique tied `path` array.
- macOS and Linux retain their intended path precedence.
- Repeated sourcing never introduces duplicate entries.
