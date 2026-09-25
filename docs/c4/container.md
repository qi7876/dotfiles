# C2: Containers

```mermaid
C4Container
    title dotfiles containers
    Person(owner, "Owner")
    Container(repo, "Configuration packages", "Files", "Shared packages plus independent macOS and Linux Zsh trees")
    Container(scripts, "Management scripts", "POSIX shell", "Selects the platform package and manages the complete link set")
    Container(tests, "Local tests", "POSIX shell", "Tests safety, conflicts, idempotency and syntax")
    Container_Ext(stow, "GNU Stow", "CLI", "Creates and removes symbolic links")
    ContainerDb(home, "Home directory", "Filesystem", "Linked configuration and private local files")

    Rel(owner, scripts, "Runs")
    Rel(scripts, tests, "Invokes during checks")
    Rel(scripts, stow, "Requests link operations")
    Rel(stow, repo, "Reads package trees")
    Rel(stow, home, "Creates or removes links")
    Rel(scripts, home, "Creates missing private files once")
```

The scripts select `shell-macos` or `shell-linux`, combine it with the applicable
packages, and preflight the complete Stow operation. Kitty is macOS-only.
Platform detection never runs inside Zsh. GNU Stow owns only symbolic links;
`~/.secrets.zsh`, `~/.config/git/credentials`, and `config.local` remain
ordinary local files. The Git directory is real so its private credentials
file stays outside the repository.
