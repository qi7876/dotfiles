# refactor/modern-zsh-tools

## Intent

Modernize FZF initialization and make Mihomo shell helpers propagate every curl,
pipeline, URI-encoding, and JSON-construction failure.

## Progress

- Switched FZF integration to native Zsh process-substitution sourcing.
- Restored FZF's overridden `.git` and `node_modules` exclusions.
- Added generated-directory exclusions for the active Rust, Python, and Astro stacks.
- Replaced complex Mihomo aliases with scoped, failure-aware functions.
- Added success and failure tests for all Mihomo query and mutation paths.

## Completion criteria

- Both platform configurations use the same tested FZF policy.
- Failed curl or jq operations always return nonzero and never call a dependent API step.
- Successful helper output remains compatible with the previous commands.
