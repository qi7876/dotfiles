# dotfiles

Personal, cross-platform shell and development-tool configuration managed with
[GNU Stow](https://www.gnu.org/software/stow/). The repository is the source of
truth for shared configuration; credentials and machine-specific values stay in
local files outside Git.

Zsh is maintained as two independent packages: `shell-macos` and `shell-linux`.
The management scripts resolve the public `shell` package from `uname`; the Zsh
files themselves contain no runtime platform detection or shared fragments.

## Prerequisites

- Git, Zsh, GNU Stow, fzf, zoxide, jq, tmux, Vim, ripgrep, and OpenSSH
- macOS: `brew install stow fzf zoxide jq tmux vim ripgrep`
- Debian/Ubuntu: install the equivalent packages with `apt`

Kitty and GitHub CLI configuration can be linked even when their applications
are not installed.

## Install

```sh
git clone <repository> ~/projects/dotfiles
cd ~/projects/dotfiles
./scripts/check.sh
./scripts/install.sh
```

Installation and removal always operate on the complete configuration set:

```sh
./scripts/install.sh
./scripts/uninstall.sh
```

Package arguments are intentionally unsupported. On macOS the scripts deploy
`shell-macos`; on Linux they deploy `shell-linux`. Other kernels are rejected
before the script creates links or local files.

Installation stops on conflicts instead of overwriting existing files. Use
`DOTFILES_TARGET=/temporary/home` to operate on a different home directory.

## Local configuration

The installer creates these files once with mode `600` and never overwrites or
removes them:

- `~/.config/dotfiles/secrets.zsh`
- `~/.ssh/config.local`

The shared `.zshenv` files configure the local proxy endpoints and Mihomo config
path with these defaults:

```sh
export http_proxy='http://127.0.0.1:7890'
export https_proxy="$http_proxy"
export no_proxy='localhost,127.0.0.1,::1'
export HTTP_PROXY="$http_proxy"
export HTTPS_PROXY="$https_proxy"
export NO_PROXY="$no_proxy"
export MIHOMO_API='http://127.0.0.1:9090'
export MIHOMO_CONFIG="$HOME/.config/mihomo/config.yaml"
```

Only the secret must be added manually to
`~/.config/dotfiles/secrets.zsh` when Mihomo authentication is enabled:

```sh
export MIHOMO_SECRET=
```

Private SSH hosts belong in `~/.ssh/config.local`. SSH keys, `known_hosts`,
GitHub CLI authentication, histories, backups, and editor state are never
tracked.

## Development

Run all local checks with `./scripts/check.sh`. Architecture notes are under
`docs/c4/`, and project status is maintained in `docs/collab/`.
