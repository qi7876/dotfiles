# dotfiles

Requires Git, Bash 5+, Fish, fzf, zoxide, jq, Neovim, and ripgrep.

```sh
./scripts/install.sh
./scripts/uninstall.sh
```

Fish loads the functions and interactive settings from `fish/config.fish`.
After installation, run `mh-reload` in Fish to reload the configuration file of
the mihomo instance at `MIHOMO_API`.

The installer creates `~/.secrets` and `~/.git-credentials` when missing with mode
`600`, preserving their contents. Secrets use Bash syntax and override defaults:
