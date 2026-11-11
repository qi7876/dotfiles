# C2: Containers

```mermaid
C4Container
    title dotfiles containers
    Person(owner, "Owner")
    Container(repo, "Configuration files", "Files", "Bash environment and Fish interactive configuration")
    Container(scripts, "Management scripts", "POSIX sh", "Manages the complete configuration link set")
    ContainerDb(home, "Home directory", "Filesystem", "Linked configuration and private local files")

    Rel(owner, scripts, "Runs")
    Rel(scripts, repo, "Reads managed files")
    Rel(scripts, home, "Creates directories and file links")
    Rel(scripts, home, "Creates missing private files once")
```

The scripts preflight every managed file link and deploy the shared `bash/` and
`fish/` configurations. The Bash login profile initializes the environment and
loads `~/.secrets`; interactive Bash replaces itself with Fish. Non-interactive
login shells initialize the environment without launching Fish. Fish inherits
exported variables and loads interactive integrations, including mise on Linux.
The installer links Git, Bash, Fish, Starship, Neovim, and dprint files using
`~/.gitconfig`, `~/.bashrc`, `~/.bash_profile`, and files below `~/.config`.
It also links `AGENTS.md` into existing tool directories.
`~/.secrets` and `~/.git-credentials` remain ordinary local files. Secrets use
Bash syntax, load after the default environment, and can override it. Installation
renames the former `~/.bash_secrets` after preflight and rejects migration when
both names exist. Uninstall preserves private files.
