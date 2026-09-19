# fix/macos-zsh-semantics

## Intent

Restore the original macOS PATH and Homebrew initialization behavior, use OSC
52 consistently for clipboard writes, and prevent false Mihomo update success
messages.

## Progress

- Unified macOS and Linux `clip` functions on OSC 52.
- Restored Rust and Node PATH initialization to macOS `.zshenv`.
- Restored fixed-path Homebrew initialization in macOS `.zprofile`.
- Made provider-update failures return without printing `Updated`.
- Added static and behavioral regression tests for both platforms.

## Completion criteria

- All local checks pass.
- Non-login macOS shells resolve Rust and Node from the configured paths.
- Failed provider updates remain failures and never print a success message.
