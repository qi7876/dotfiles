# dotfiles

Personal, cross-platform shell and development-tool configuration installed
with individual symbolic links. The repository is the source of truth for
shared configuration; credentials and machine-specific values stay in local
files outside Git.

Zsh is maintained as two independent packages: `shell-macos` and `shell-linux`.
The management scripts resolve the public `shell` package from `uname`; the Zsh
files themselves contain no runtime platform detection or shared fragments.

## Prerequisites

- Jujustu, Git, Zsh, fzf, zoxide, jq, tmux, Neovim, ripgrep, and OpenSSH
- macOS: `brew install jj fzf zoxide jq tmux neovim ripgrep`
- Ubuntu: install the equivalent packages with `apt`

Kitty configuration is deployed only on macOS.

## Install

```sh
git clone <repository> ~/projects/dotfiles
cd ~/projects/dotfiles
./scripts/install.sh
```

Installation and removal always operate on the complete configuration set:

```sh
./scripts/install.sh
./scripts/uninstall.sh
```

Package arguments are intentionally unsupported. On macOS the scripts deploy
`shell-macos` and Kitty; on Linux they deploy `shell-linux` without Kitty.
The management scripts require Zsh.

The installer creates real directories and links each managed file separately.
Repository tool directories contain only their configuration files; the link
destinations are defined in `scripts/install.sh` and `scripts/uninstall.sh`.
Installation reports all path conflicts before creating files or links and
does not overwrite existing files. Use
`HOME=/temporary/home` to operate on a different home directory.
Existing directory links and former Git or tmux home-directory links are not
migrated; remove them manually before using the new layout.

## Local configuration

The installer creates these files empty when missing, sets mode `600`, and
never overwrites or removes their contents:

- `~/.config/git/credentials`
- `~/.secrets.zsh`
- `~/.ssh/config.local`

The shared `.zshenv` files configure the local proxy endpoints and Mihomo API
endpoint with these defaults:

```sh
export http_proxy='http://127.0.0.1:7890'
export https_proxy="$http_proxy"
export no_proxy='localhost,127.0.0.1,::1'
export HTTP_PROXY="$http_proxy"
export HTTPS_PROXY="$https_proxy"
export NO_PROXY="$no_proxy"
export MIHOMO_API='http://127.0.0.1:9090'
```

Add the Mihomo secret to `~/.secrets.zsh` when authentication is enabled:

```sh
export MIHOMO_SECRET=
```

Git uses `credential-store` with `~/.config/git/credentials`. Add credentials
there when needed; it starts empty and stores them as plain text.

Git, tmux, and Neovim are linked to `~/.config/git/config`,
`~/.config/tmux/tmux.conf`, and `~/.config/nvim/init.lua`. Kitty files are
linked individually inside `~/.config/kitty` on macOS. The root
`AGENTS.md` is linked into each existing `~/.codex` and `~/.dsh`
directory; the installer does not create those directories.

Private SSH hosts belong in `~/.ssh/config.local`. SSH keys, `known_hosts`,
histories, backups, and editor state are never tracked.

## Development

The maintained architecture views are the
[system context](docs/architecture/system-context.md) and
[container](docs/architecture/container.md) diagrams.

## Status

- macOS and Linux use separate Zsh packages; Kitty is installed on macOS only.
- Install, uninstall, and local checks run against the complete package set.

## Next

- Add new tools as independent configuration directories when needed.
