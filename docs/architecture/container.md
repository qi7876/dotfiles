# C2: Containers

```mermaid
C4Container
    title dotfiles containers
    Person(owner, "Owner")
    Container(repo, "Configuration files", "Files", "Root configuration plus macOS and Linux Stow packages")
    Container(scripts, "Management scripts", "POSIX shell", "Selects the platform package and manages the complete link set")
    Container(tests, "Local tests", "POSIX shell", "Tests safety, conflicts, idempotency and syntax")
    Container_Ext(stow, "GNU Stow", "CLI", "Creates and removes symbolic links")
    ContainerDb(home, "Home directory", "Filesystem", "Linked configuration and private local files")

    Rel(owner, scripts, "Runs")
    Rel(scripts, tests, "Invokes during checks")
    Rel(scripts, stow, "Requests link operations")
    Rel(stow, repo, "Reads package trees")
    Rel(stow, home, "Creates or removes links")
    Rel(scripts, home, "Links root configuration and AGENTS.md")
    Rel(scripts, home, "Creates missing private files once")
```

The scripts select `shell-macos` or `shell-linux` and preflight the applicable
Stow packages and direct links. Kitty is macOS-only. Platform detection never
runs inside Zsh. The installer links root Git, Vim, and tmux files into home and
links `AGENTS.md` into existing tool directories. `~/.secrets.zsh`,
`~/.git-credentials`, and `config.local` remain ordinary local files.
