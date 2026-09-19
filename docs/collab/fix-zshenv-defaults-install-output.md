# fix/zshenv-defaults-install-output

## Intent

Move documented, non-secret shell environment defaults into both platform
`.zshenv` files and keep successful installation output free of GNU Stow's
preflight simulation warning.

## Progress

- Added failing behavior coverage for the environment defaults and installer output.
- Added proxy and Mihomo non-secret defaults to both platform `.zshenv` files.
- Kept the Stow preflight quiet on success and diagnostic on failure.
- Updated the local secret template and README guidance.
- Passed the complete local check suite.

## Next

- Merge this short-lived branch after review.
