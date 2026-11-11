# dotfiles

Personal, cross-platform shell and development-tool configuration installed
with individual symbolic links.

## Prerequisites

Git, Bash 3.2 or newer, fzf, zoxide, Starship, jq, Neovim, and ripgrep.
macOS also requires Homebrew; Linux requires mise.

Ghostty configuration is deployed only on macOS.
The `s` alias invokes `ssh`.

## Install

Installation and removal always operate on the complete configuration set:

```sh
./scripts/install.sh
./scripts/uninstall.sh
```

Both platforms use the shared `bash/` configuration and Bash functions.
Ghostty is deployed only on macOS. The management scripts use POSIX sh and do not
require Bash to run.
Bash uses Readline completion and appends command history to `~/.bash_history`.
PATH additions are process-local and skip directories that do not exist.

The installer creates real directories and links each managed file separately.
Installation reports all path conflicts before creating files or links and
does not overwrite existing files.

Login shells source `~/.bashrc` through `~/.bash_profile`; interactive non-login
shells read `~/.bashrc` directly. Non-interactive shells only load this configuration
when it is explicitly sourced or started as a login shell.

When migrating from fish, remove the old managed links with the previous
revision's `scripts/uninstall.sh` before installing this revision. Back up any
existing `~/.bashrc` and `~/.bash_profile` that conflict with installation.
Translate private settings from `~/.config/fish/secrets.fish` into
`~/.config/bash/secrets.bash`; fish syntax cannot be sourced by Bash.
The installer does not change your login shell. After installation, use
`chsh -s /bin/bash` to select the system Bash, then open a new terminal.

## Local configuration

The installer creates these files empty when missing, sets mode `600`, and
never overwrites or removes their contents:

- `~/.config/git/credentials`
- `~/.config/bash/secrets.bash`

`secrets.bash` uses Bash syntax and loads after the default environment settings,
so it can override them (for example, `export MIHOMO_SECRET=value`).

## Mihomo

Use `mh-set-mode global`, `mh-set-mode direct`, or `mh-set-mode rule` to switch
the running Mihomo instance's routing mode. These functions use `MIHOMO_API`
(default `http://127.0.0.1:9090`) and the optional `MIHOMO_SECRET`.
Mode changes use the [Mihomo configuration API](https://wiki.metacubex.one/api/).

## Development

The maintained architecture views are the
[system context](docs/architecture/system-context.md) and
[container](docs/architecture/container.md) diagrams.
