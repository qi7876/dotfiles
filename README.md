# dotfiles

Requires Git, Bash 5+, Fish, fzf, zoxide, jq, Neovim, and ripgrep.

```sh
./scripts/install.sh
./scripts/uninstall.sh
```

The installer creates `~/.secrets` and `~/.git-credentials` when missing with mode
`600`, preserving their contents. Secrets use Bash syntax and override defaults:
