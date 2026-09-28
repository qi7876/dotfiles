# C2: Containers

```mermaid
C4Container
    title dotfiles containers
    Person(owner, "Owner")
    Container(repo, "Configuration files", "Files", "Shared configuration plus macOS and Linux shell files")
    Container(scripts, "Management scripts", "POSIX shell", "Selects platform files and manages the complete link set")
    Container(tests, "Local tests", "POSIX shell", "Tests safety, conflicts, idempotency and syntax")
    ContainerDb(home, "Home directory", "Filesystem", "Linked configuration and private local files")

    Rel(owner, scripts, "Runs")
    Rel(scripts, tests, "Invokes during checks")
    Rel(scripts, repo, "Reads managed files")
    Rel(scripts, home, "Creates directories and file links")
    Rel(scripts, home, "Creates missing private files once")
```

The scripts select `shell-macos` or `shell-linux` and preflight every managed
file link. Kitty is macOS-only. Platform detection never runs inside Zsh. The
installer links Git, tmux, and Neovim files below `~/.config` and links
`AGENTS.md` into existing tool directories. `~/.secrets.zsh`,
`~/.git-credentials`, and `config.local` remain ordinary local files.
