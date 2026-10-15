# dotfiles

Personal, cross-platform shell and development-tool configuration installed
with individual symbolic links.

## Prerequisites

Git, Zsh, fzf, zoxide, jq, tmux, Neovim, and ripgrep

Kitty configuration is deployed only on macOS.

## Install

Installation and removal always operate on the complete configuration set:

```sh
./scripts/install.sh
./scripts/uninstall.sh
```

On macOS the scripts deploy `shell-macos` and Kitty;
on Linux they deploy `shell-linux` without Kitty.
The management scripts require Zsh.

The installer creates real directories and links each managed file separately.
Installation reports all path conflicts before creating files or links and
does not overwrite existing files.

## Local configuration

The installer creates these files empty when missing, sets mode `600`, and
never overwrites or removes their contents:

- `~/.config/git/credentials`
- `~/.secrets.zsh`

## Development

The maintained architecture views are the
[system context](docs/architecture/system-context.md) and
[container](docs/architecture/container.md) diagrams.
