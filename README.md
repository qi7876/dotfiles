# dotfiles

Personal, cross-platform shell and development-tool configuration installed
with individual symbolic links.

## Prerequisites

Git, fish, fzf, zoxide, Starship, jq, Neovim, and ripgrep.
macOS also requires Homebrew; Linux requires mise.

Ghostty configuration is deployed only on macOS.
The `s` alias uses `ghostty +ssh --`, so Ghostty must be available on `PATH`
and its build must support the `+ssh` action.

## Install

Installation and removal always operate on the complete configuration set:

```sh
./scripts/install.fish
./scripts/uninstall.fish
```

Both platforms use the shared `fish/` configuration and native fish functions.
Ghostty is deployed only on macOS. The management scripts require fish.
Fish uses its native history and completion support.
PATH additions are process-local and skip directories that do not exist.

The installer creates real directories and links each managed file separately.
Installation reports all path conflicts before creating files or links and
does not overwrite existing files.

## Local configuration

The installer creates these files empty when missing, sets mode `600`, and
never overwrites or removes their contents:

- `~/.config/git/credentials`
- `~/.config/fish/secrets.fish`

`secrets.fish` uses fish syntax and loads after the default environment settings,
so it can override them (for example, `set -gx MIHOMO_SECRET value`).

## Development

The maintained architecture views are the
[system context](docs/architecture/system-context.md) and
[container](docs/architecture/container.md) diagrams.
