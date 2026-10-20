# C2: Containers

```mermaid
C4Container
    title dotfiles containers
    Person(owner, "Owner")
    Container(repo, "Configuration files", "Files", "Shared configuration and native fish functions")
    Container(scripts, "Management scripts", "POSIX sh", "Manages the complete link set and macOS-only Ghostty files")
    ContainerDb(home, "Home directory", "Filesystem", "Linked configuration and private local files")

    Rel(owner, scripts, "Runs")
    Rel(scripts, repo, "Reads managed files")
    Rel(scripts, home, "Creates directories and file links")
    Rel(scripts, home, "Creates missing private files once")
```

The scripts preflight every managed file link and deploy the shared `fish/`
configuration. Fish detects the platform for macOS Homebrew paths and Linux mise
initialization; interactive integrations only load in interactive shells.
Ghostty is macOS-only. The installer links Git, fish, Starship, Neovim, and dprint files
below `~/.config` and links `AGENTS.md` into existing tool directories.
`~/.config/fish/secrets.fish`, `~/.config/git/credentials`, and `config.local`
remain ordinary local files. Secrets load after the default shell environment
and can override it. Uninstall preserves private files.
