# dotfiles

Personal, cross-platform shell and development-tool configuration managed with
[GNU Stow](https://www.gnu.org/software/stow/). The repository is the source of
truth for shared configuration; credentials and machine-specific values stay in
local files outside Git.

## Prerequisites

- Git, Zsh, GNU Stow, fzf, zoxide, jq, tmux, and Vim
- macOS: `brew install stow fzf zoxide jq tmux vim`
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

Install or remove selected packages by passing their names:

```sh
./scripts/install.sh shell git tmux
./scripts/uninstall.sh shell git tmux
```

Installation stops on conflicts instead of overwriting existing files. Use
`DOTFILES_TARGET=/temporary/home` to operate on a different home directory.

## Local configuration

The installer creates these files once with mode `600` and never overwrites or
removes them:

- `~/.config/dotfiles/secrets.zsh`
- `~/.ssh/config.local`

For the current shell helpers, add the required values manually:

```sh
export http_proxy='http://127.0.0.1:7890'
export https_proxy="$http_proxy"
export no_proxy='localhost,127.0.0.1,::1'
export HTTP_PROXY="$http_proxy"
export HTTPS_PROXY="$https_proxy"
export NO_PROXY="$no_proxy"
export MIHOMO_API='http://127.0.0.1:9090'
export MIHOMO_SECRET=
export MIHOMO_CONFIG='/path/to/mihomo/config.yaml'
```

Private SSH hosts belong in `~/.ssh/config.local`. SSH keys, `known_hosts`,
GitHub CLI authentication, histories, backups, and editor state are never
tracked.

## Development

Run all local checks with `./scripts/check.sh`. Architecture notes are under
`docs/c4/`, and project status is maintained in `docs/collab/`.
