# fix/linux-headless-packages

## Intent

Keep Kitty configuration on macOS while treating Linux targets as SSH-only
hosts, and remove redundant guidance comments from local file templates.

## Progress

- Added failing integration coverage for platform-specific Kitty deployment.
- Split the platform package sets and added Linux cleanup for legacy Kitty links.
- Removed redundant comments from both local file templates.
- Updated the README, C2 architecture notes, and main project status.
- Removed stale README and test references left after `MIHOMO_CONFIG` and
  `mh-reload` were removed on `main`.
- Passed the complete local check suite.

## Next

- Merge this short-lived branch after review.
