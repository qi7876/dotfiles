# refactor/remove-gh-config

## Intent

Stop managing GitHub CLI configuration because `gh` already generates suitable
defaults, while preserving the current machine's local authentication state.

## Progress

- Added failing coverage that rejects a repository-owned `gh` package and GH
  configuration deployment.
- Migrated the current machine's linked GH configuration to
  `~/.config/gh` as ordinary local files without losing authentication state.
- Removed the `gh` package from management scripts and the repository.
- Removed GH validation and updated current README, architecture, and project
  status documentation.
- Passed the complete local check suite.

## Next

- Merge this short-lived branch after review.
