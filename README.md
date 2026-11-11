# dotfiles

Personal, cross-platform shell and development-tool configuration installed
with individual symbolic links.

## Prerequisites

Git, Bash, Fish, fzf, zoxide, Starship, jq, Neovim, and ripgrep.
macOS also requires Homebrew; Linux requires mise.

Ghostty configuration is deployed only on macOS.
The `s` alias invokes `ssh`.

## Install

Installation and removal always operate on the complete configuration set:

```sh
./scripts/install.sh
./scripts/uninstall.sh
```

Both platforms use Bash as the login shell for environment initialization and
Fish for interactive use. `.bash_profile` initializes Homebrew, PATH, editor,
proxy, and other exported variables, then loads `~/.secrets` using Bash syntax.
Interactive Bash shells replace themselves with Fish through `.bashrc`.
Fish inherits the environment and provides functions, aliases, completion,
command history, fzf, zoxide, Starship, and Linux mise activation.
The management scripts use POSIX sh and do not require Bash to run.
PATH additions are process-local and prepended directly without deduplication.

The installer links Git configuration at `~/.gitconfig`, creates real directories,
and links each managed file separately.
Installation reports all path conflicts before creating files or links and
does not overwrite existing files.

Non-interactive login Bash shells initialize the environment without starting
Fish. Non-login Bash shells inherit their parent's environment; non-interactive
ones do not load these files automatically. Start terminals through the Bash
login shell so Fish inherits the initialized environment. Running Fish directly
does not load `~/.secrets` or the Bash environment defaults.

The installer does not change your account's login shell. Use
`chsh -s /bin/bash` on macOS or Linux, or keep an existing Homebrew Bash login
shell. The chosen executable must be listed in `/etc/shells`.
Then open a new terminal. Use `bash --norc` for an interactive Bash session.

## Local configuration

The installer creates these files empty when missing, sets mode `600`, and
never overwrites or removes their contents:

- `~/.git-credentials`
- `~/.secrets`

`.secrets` uses Bash syntax and loads after the default environment settings,
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
