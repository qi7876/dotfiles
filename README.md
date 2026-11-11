# dotfiles

Personal macOS and Linux configuration for Bash, Fish, Git, Neovim, Starship,
and dprint, installed through individual symbolic links.

## Install

Requires Git, Bash 5+, Fish, fzf, zoxide, Starship, jq, Neovim, and ripgrep.
macOS uses Homebrew (`brew install bash`); Linux also requires mise.

```sh
./scripts/install.sh
./scripts/uninstall.sh
```

The scripts manage the complete configuration set. Installation reports conflicts
without overwriting existing files. Uninstall preserves private files.

Set Bash as your login shell using `chsh -s /opt/homebrew/bin/bash` on Apple
Silicon macOS or `chsh -s /bin/bash` on Linux. The executable must be Bash 5+
and listed in `/etc/shells`; the installer does not change it.

## Shells and local settings

Start terminals as Bash login shells. `.bash_profile` initializes the shared
environment, including fzf defaults and Linux mise shims, then loads `~/.secrets`.
`.bashrc` provides interactive aliases, history, fzf, zoxide, Starship, and Linux
mise activation. Non-interactive login shells only initialize the environment.

Run `fish` to enter Fish and `exit` to return to Bash. Fish inherits the exported
environment, initializes its interactive tools, and provides `copy` and Mihomo
functions. Starting Fish directly does not load the Bash environment or secrets.
Starship displays the current shell name.

The installer creates `~/.secrets` and `~/.git-credentials` when missing with mode
`600`, preserving their contents. Secrets use Bash syntax and override defaults:

```sh
export MIHOMO_SECRET=value
export FZF_DEFAULT_OPTS='--height=40%'
```

Both shells share `ls` (color and type markers), `ll` (detailed listing including
hidden files), `g=git`, `n=nvim`, `s=ssh`, and `nv` (GPU statistics).

## Mihomo

In Fish, use `mh-set-mode global`, `mh-set-mode direct`, or `mh-set-mode rule`.
Mihomo functions use `MIHOMO_API` (default `http://127.0.0.1:9090`) and optional
`MIHOMO_SECRET` from the login environment.

## Architecture

See the [system context](docs/architecture/system-context.md) and
[container](docs/architecture/container.md) views.
